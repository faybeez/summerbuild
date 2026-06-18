import "@supabase/functions-js/edge-runtime.d.ts";
import { withSupabase } from "@supabase/server";
import type { Database } from "../database.types.ts";

// Example request body
// {
//   "name": "Summer Look",
//   "description": "Light and breezy",
//   "rating": 4,
//   "tagIds": [12, 7],
//   "clothes": [
//     { "clothesId": 101, "slot": "OUTFIT", "sortOrder": 0 },
//     { "clothesId": 204, "slot": "ACCESSORIES", "sortOrder": 1 }
//   ]
// }

interface OutfitClothesInput {
  clothesId: number;
  slot?: "ACCESSORIES" | "OUTFIT" | null;
  sortOrder?: number;
}

interface CreateOutfitBody {
  name?: string | null;
  description?: string | null;
  rating?: number | null;
  tagIds?: number[];
  clothes?: OutfitClothesInput[];
}

export default {
  fetch: withSupabase<Database>({ auth: "user" }, async (req, ctx) => {
    const { userClaims, supabase } = ctx;

    if (!userClaims) {
      return Response.json({ error: "Unauthorized" }, { status: 401 });
    }

    if (req.method !== "POST") {
      return Response.json({ error: "Method not allowed" }, { status: 405 });
    }

    let body: CreateOutfitBody;
    try {
      body = await req.json();
    } catch {
      return Response.json({ error: "Invalid JSON body" }, { status: 400 });
    }

    const { name, description, rating, tagIds = [], clothes = [] } = body;

    const { data: outfit, error: outfitError } = await supabase
      .from("outfits")
      .insert({
        user_id: userClaims.id,
        name: name ?? null,
        description: description ?? null,
        rating: rating ?? null,
      })
      .select("id")
      .single();

    if (outfitError || !outfit) {
      return Response.json(
        { error: outfitError?.message ?? "Failed to create outfit" },
        { status: 500 },
      );
    }

    const outfitId = outfit.id;
    const errors: string[] = [];

    if (tagIds.length > 0) {
      const { error: tagsError } = await supabase.from("outfits_tags").insert(
        tagIds.map((tagId) => ({
          outfit_id: outfitId,
          tag_id: tagId,
        })),
      );
      if (tagsError) errors.push(`tags: ${tagsError.message}`);
    }

    if (clothes.length > 0) {
      const { error: clothesError } = await supabase
        .from("outfit_clothes")
        .insert(
          clothes.map((c, index) => ({
            outfit_id: outfitId,
            clothes_id: c.clothesId,
            slot: c.slot ?? null,
            sort_order: c.sortOrder ?? index,
          })),
        );
      if (clothesError) errors.push(`clothes: ${clothesError.message}`);
    }

    if (errors.length > 0) {
      return Response.json(
        {
          error: "Outfit created but some relations failed",
          details: errors,
          outfitId,
        },
        { status: 207 },
      );
    }

    return Response.json({ outfitId }, { status: 201 });
  }),
};
