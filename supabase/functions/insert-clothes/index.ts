import "@supabase/functions-js/edge-runtime.d.ts";
import { withSupabase } from "@supabase/server";
import type { Database } from "../database.types.ts";

type ClothesInsert = Database["public"]["Tables"]["clothes"]["Insert"];
type ClothesTagsInsert = Database["public"]["Tables"]["clothes_tags"]["Insert"];

export default {
  fetch: withSupabase<Database>({ auth: "user" }, async (req, ctx) => {
    const { supabase, userClaims } = ctx;

    if (!userClaims) {
      return Response.json({ error: "Unauthorized" }, { status: 401 });
    }

    const formData = await req.formData();

    const cost = Number(formData.get("cost"));
    const times_worn = Number(formData.get("times_worn") ?? 0);
    const tag_ids = JSON.parse(
      String(formData.get("tag_ids") ?? "[]"),
    ) as number[];
    const image = formData.get("image") as File | null;

    if (!image) {
      return Response.json({ error: "Image is required" }, { status: 400 });
    }

    if (!(image instanceof File)) {
      return Response.json({ error: "Image is invalid" }, { status: 400 });
    }

    try {
      const user_id = userClaims.id;
      const image_type = image.type.split("/")[1] || "png";

      // insert main clothes item
      const clothesInsert: ClothesInsert = {
        cost: cost,
        times_worn: times_worn,
        user_id: user_id,
        image_type: image_type,
      };

      const { data: clothes, error: clothesError } = await supabase
        .from("clothes")
        .insert(clothesInsert)
        .select();

      if (clothesError) {
        return Response.json(
          { error: "Failed to insert clothes" },
          { status: 400 },
        );
      }

      const clothes_id = clothes[0].id;

      // insert photos to bucket
      const { data: _, error: imageError } = await supabase.storage
        .from("clothes_photos")
        .upload(`${user_id}/${clothes_id}.${image_type}`, image, {
          contentType: image.type,
          upsert: true, // overwrite existing files
        });

      if (imageError) {
        console.error("Storage upload error:", imageError);
        console.error("Storage upload error details:", {
          name: imageError.name,
          message: imageError.message,
        });
        throw new Error("Failed to upload image to storage");
      }

      // insert tags
      const tags: ClothesTagsInsert[] = tag_ids.map((id: number) => ({
        clothes_id,
        tag_id: id,
      }));

      console.log("Inserting tags:", tags);

      if (tags.length > 0) {
        const { data: _, error: tagsError } = await supabase
          .from("clothes_tags")
          .insert(tags);

        if (tagsError) {
          console.error("Tags insert error:", tagsError);
          return Response.json(
            { error: "Failed to insert tags" },
            { status: 400 },
          );
        }
      }
    } catch (error: unknown) {
      if (error instanceof Error) {
        console.error("Error message:", error.message);
      } else {
        console.error("An unexpected error occurred:", error);
      }
      return Response.json({ error: "Internal server error" }, { status: 500 });
    }

    return Response.json(
      { message: "Clothes inserted successfully" },
      { status: 200 },
    );
  }),
};
