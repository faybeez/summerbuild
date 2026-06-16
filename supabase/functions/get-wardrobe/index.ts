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
    const cursor = url.searchParams.get("cursor"); // ISO timestamp of last item

    let query = supabase
      .from("clothes")
      .select("id, image_type, cost, times_worn, created_at")
      .eq("user_id", userClaims.id)
      .order("created_at", { ascending: false })
      .limit(PAGE_SIZE);

    if (cursor) {
      query = query.lt("created_at", cursor);
    }

    const { data: items, error } = await query;

    if (error) {
      return Response.json({ error: error.message }, { status: 500 });
    }

    const itemIds = items.map((i) => i.id);

    const { data: tagsData, error: tagsError } = await supabase
      .from("clothes_tags")
      .select("clothes_id, tags(*)")
      .in("clothes_id", itemIds);

    if (tagsError) {
      return Response.json({ error: tagsError.message }, { status: 500 });
    }

    const paths = items.map((i) => `${userClaims.id}/${i.id}.${i.image_type}`);
    const { data: signedUrls } = await supabase.storage
      .from("clothes_photos")
      .createSignedUrls(paths, 3600);

    console.log("Signed URLs:", signedUrls);

    const urlMap = Object.fromEntries(
      (signedUrls ?? [])
        .filter((s) => s.signedUrl)
        .map((s) => [s.path, s.signedUrl]),
    );

    console.log("URL Map:", urlMap);
    const result = items.map((item) => ({
      id: item.id,
      imageUrl:
        urlMap[`${userClaims.id}/${item.id}.${item.image_type}`] ?? null,
      cost: item.cost,
      timesWorn: item.times_worn,
      createdAt: item.created_at,
      tags:
        tagsData!
          .filter((x) => x.clothes_id === item.id)
          .flatMap((x) => x.tags) ?? [],
    }));

    return Response.json(
      {
        items: result,
        hasMore: items.length === PAGE_SIZE,
        cursor: items.length > 0 ? items[items.length - 1].created_at : null,
      },
      { status: 200 },
    );
  }),
};
