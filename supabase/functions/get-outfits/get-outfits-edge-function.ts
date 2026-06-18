import "@supabase/functions-js/edge-runtime.d.ts";
import { withSupabase } from "@supabase/server";
import type { Database } from "../database.types.ts";

const PAGE_SIZE = 12;

export default {
  fetch: withSupabase<Database>({ auth: "user" }, async (req, ctx) => {
    const { userClaims, supabase } = ctx;

    if (!userClaims) {
      return Response.json({ error: "Unauthorized" }, { status: 401 });
    }

    const url = new URL(req.url);
    const cursor = url.searchParams.get("cursor");

    let query = supabase
      .from("outfits")
      .select("id, name, description, rating, created_at, edited_at")
      .eq("user_id", userClaims.id)
      .order("created_at", { ascending: false })
      .limit(PAGE_SIZE);

    if (cursor) {
      query = query.lt("created_at", cursor);
    }

    const { data: outfits, error: outfitsError } = await query;

    if (outfitsError) {
      return Response.json({ error: outfitsError.message }, { status: 500 });
    }

    const outfitIds = outfits.map((o) => o.id);

    if (outfitIds.length === 0) {
      return Response.json(
        { items: [], hasMore: false, cursor: null },
        { status: 200 },
      );
    }

    const [
      { data: outfitTagsData, error: outfitTagsError },
      { data: outfitClothesData, error: outfitClothesError },
    ] = await Promise.all([
      supabase
        .from("outfits_tags")
        .select("outfit_id, tags(*)")
        .in("outfit_id", outfitIds),
      supabase
        .from("outfit_clothes")
        .select(
          "outfit_id, clothes_id, slot, sort_order, clothes(id, image_type)",
        )
        .in("outfit_id", outfitIds)
        .order("sort_order", { ascending: true }),
    ]);

    if (outfitTagsError) {
      return Response.json({ error: outfitTagsError.message }, { status: 500 });
    }

    if (outfitClothesError) {
      return Response.json(
        { error: outfitClothesError.message },
        { status: 500 },
      );
    }

    const clothesPaths = (outfitClothesData ?? [])
      .filter((oc) => oc.clothes?.image_type)
      .map(
        (oc) => `${userClaims.id}/${oc.clothes_id}.${oc.clothes!.image_type}`,
      );

    const uniquePaths = [...new Set(clothesPaths)];

    const { data: signedUrls } = await supabase.storage
      .from("clothes_photos")
      .createSignedUrls(uniquePaths, 3600);

    const urlMap = Object.fromEntries(
      (signedUrls ?? [])
        .filter((s) => s.signedUrl)
        .map((s) => [s.path, s.signedUrl]),
    );

    const result = outfits.map((outfit) => {
      const clothes = (outfitClothesData ?? [])
        .filter((oc) => oc.outfit_id === outfit.id)
        .map((oc) => ({
          clothesId: oc.clothes_id,
          slot: oc.slot ?? null,
          sortOrder: oc.sort_order,
          imageUrl:
            urlMap[
              `${userClaims.id}/${oc.clothes_id}.${oc.clothes?.image_type}`
            ] ?? null,
        }));

      const tags = (outfitTagsData ?? [])
        .filter((ot) => ot.outfit_id === outfit.id)
        .flatMap((ot) => ot.tags);

      return {
        id: outfit.id,
        name: outfit.name ?? null,
        description: outfit.description ?? null,
        rating: outfit.rating ?? null,
        createdAt: outfit.created_at,
        editedAt: outfit.edited_at,
        tags,
        clothes,
      };
    });

    return Response.json(
      {
        items: result,
        hasMore: outfits.length === PAGE_SIZE,
        cursor:
          outfits.length > 0 ? outfits[outfits.length - 1].created_at : null,
      },
      { status: 200 },
    );
  }),
};
