import { SupabaseClient } from "@supabase/supabase-js";

export async function seedClothesImages(supabase: SupabaseClient) {
  const bucket = "clothes_images";
  const uuid = ""; // insert uuid here

  const files = [
    {
      localPath: "../images/1.jpg",
      storagePath: `${uuid}/1.jpg`,
      contentType: "image/jpeg",
    },
  ];

  for (const file of files) {
    const bytes = await Deno.readFile(file.localPath);

    const { error } = await supabase.storage
      .from(bucket)
      .upload(file.storagePath, bytes, {
        contentType: file.contentType,
        upsert: true,
      });

    if (error) {
      throw new Error(`seedStorage failed: ${error.message}`);
    }

    console.log(`Uploaded ${file.storagePath}`);
  }
}
