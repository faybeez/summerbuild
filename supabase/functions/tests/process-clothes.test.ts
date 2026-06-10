import { assertEquals } from "@std/assert";
import { createClient, SupabaseClient } from "@supabase/supabase-js";
import { requiredEnv } from "./sharedFunctions.ts";

const SUPABASE_URL = requiredEnv("SUPABASE_URL");
const SUPABASE_ANON_KEY = requiredEnv("SUPABASE_ANON_KEY");
const EMAIL = requiredEnv("EMAIL");
const PASSWORD = requiredEnv("PASSWORD");
const IMAGE_PATH = requiredEnv("IMAGE_PATH2");
const OPTIONS = {
  auth: {
    autoRefreshToken: false,
    persistSession: false,
    detectSessionInUrl: false,
  },
};

function getFileName(path: string): string {
  return path.split(/[\\/]/).pop() ?? "photo.png";
}

Deno.test("process-clothes", async () => {
  var client: SupabaseClient = createClient(
    SUPABASE_URL,
    SUPABASE_ANON_KEY,
    OPTIONS,
  );

  const imageBytes = await Deno.readFile(IMAGE_PATH);
  const fileName = getFileName(IMAGE_PATH);

  const formData = new FormData();
  formData.append(
    "image",
    new File([imageBytes], fileName, { type: "image/png" }),
  );

  const { data, error } = await client.auth.signInWithPassword({
    email: EMAIL,
    password: PASSWORD,
  });

  if (error) {
    console.error("Login error:", error);
    throw new Error("Failed to log in");
  }
  const accessToken = data.session!.access_token;

  const { response } = await client.functions.invoke("process-clothes", {
    headers: {
      apikey: SUPABASE_ANON_KEY,
      Authorization: `Bearer ${accessToken}`,
    },
    body: formData,
  });
  if (!response) {
    console.error("Function invocation error:");
    throw new Error("Failed to invoke function");
  } else {
    assertEquals(
      response.status,
      200,
      `Expected 200 but got ${response.status}.`,
    );
  }
});
