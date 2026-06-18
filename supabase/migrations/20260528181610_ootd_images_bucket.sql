INSERT INTO "storage"."buckets" (
    "id",
    "name",
    "owner",
    "created_at",
    "updated_at",
    "public",
    "avif_autodetection",
    "allowed_mime_types",
    "owner_id",
    "type"
) VALUES (
    'ootd_images',
    'ootd_images',
    NULL,
    now(),
    now(),
    false,
    false,
    NULL,
    NULL,
    'STANDARD'
)
ON CONFLICT ("id") DO NOTHING;

CREATE POLICY "Give users access to own ootd_images folder 0"
ON storage.objects
FOR SELECT
TO authenticated
USING (
    bucket_id = 'ootd_images'
    AND (select auth.uid()::text) = (storage.foldername(name))[1]
);

CREATE POLICY "Give users access to own ootd_images folder 1"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'ootd_images'
    AND (select auth.uid()::text) = (storage.foldername(name))[1]
);

CREATE POLICY "Give users access to own ootd_images folder 2"
ON storage.objects
FOR UPDATE
TO authenticated
USING (
    bucket_id = 'ootd_images'
    AND (select auth.uid()::text) = (storage.foldername(name))[1]
);

CREATE POLICY "Give users access to own ootd_images folder 3"
ON storage.objects
FOR DELETE
TO authenticated
USING (
    bucket_id = 'ootd_images'
    AND (select auth.uid()::text) = (storage.foldername(name))[1]
);

-- Triggers
CREATE OR REPLACE FUNCTION public.handle_new_user_ootd_images_folder()
RETURNS trigger AS $$
BEGIN
  INSERT INTO storage.objects (bucket_id, name, owner, metadata)
  VALUES (
    'ootd_images',
    NEW.id || '/.keep',
    NEW.id,
    '{"mimetype": "text/plain"}'::jsonb
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Create the trigger on the auth.users table
CREATE TRIGGER on_auth_user_created_ootd_images_folder
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user_ootd_images_folder();
