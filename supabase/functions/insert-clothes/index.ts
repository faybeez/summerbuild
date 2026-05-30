import "@supabase/functions-js/edge-runtime.d.ts";
import { withSupabase } from "@supabase/server";

interface ReqPayload {
  cost: number;
  times_worn: number;
  tag_ids: number[];
  image: File;
}

export default {
  fetch: withSupabase({ auth: "user" }, async (req, ctx) => {
    const { supabase, userClaims } = ctx

    if (!userClaims) {
      return Response.json({ error: "Unauthorized" }, { status: 401 });
    }

    const formData = await req.formData();

    const cost = Number(formData.get("cost"));
    const times_worn = Number(formData.get("times_worn") ?? 0);
    const tag_ids = JSON.parse(String(formData.get("tag_ids") ?? "[]")) as number[];
    const image = formData.get("image") as File | null;

    if (!image) {
    return Response.json(
        { error: "Image is required" },
        { status: 400 }
    );
    }

    try {
      const user_id = userClaims.id;

      // insert main clothes item
        const clothesInsert = {
            'cost': cost,
            'times_worn': times_worn,
            'user_id': user_id
        }

      const { data } = await supabase
      .from('clothes')
      .insert(clothesInsert)
      .select();

      const clothes_id = data.id;

      // insert photos to bucket
      await supabase.storage
      .from('clothes_photos')
      .upload(`${user_id}/${clothes_id}`, image, {
        contentType: image.type,
        upsert: true // overwrite existing files
      });
      
      // insert tags
      const tags: Array<{ clothes_id: number; tag_id: number }> = tag_ids.map((id: number) => ({
        clothes_id,
        tag_id: id
        }));

      if (tags.length > 0) {
        await supabase
            .from('clothes_tags')
            .insert(tags);
      }

    }
    catch (error: unknown) {
      if (error instanceof Error) {
        console.error("Error message:", error.message);
      } else {
        console.error("An unexpected error occurred:", error);
      }
      return Response.json(null, {status: 500});
    }

    return Response.json(null, {status: 200});
  }),
};