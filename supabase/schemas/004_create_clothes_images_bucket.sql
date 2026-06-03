insert into storage.buckets (
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types
)
values (
  'clothes',
  'clothes',
  false,
  5242880,
  array[
    'image/jpeg',
    'image/png',
    'image/webp'
  ]
)
on conflict (id) do nothing;

CREATE POLICY "Give users access to own folder 14u3azc_1" ON storage.objects FOR INSERT TO authenticated WITH CHECK (bucket_id = 'clothes_photos' AND (select auth.uid()::text) = (storage.foldername(name))[1]);

CREATE POLICY "Give users access to own folder 14u3azc_2" ON storage.objects FOR INSERT TO authenticated WITH CHECK (bucket_id = 'clothes_photos' AND (select auth.uid()::text) = (storage.foldername(name))[1]);

CREATE POLICY "Give users access to own folder 14u3azc_3" ON storage.objects FOR UPDATE TO authenticated USING (bucket_id = 'clothes_photos' AND (select auth.uid()::text) = (storage.foldername(name))[1]);

CREATE POLICY "Give users access to own folder 14u3azc_4" ON storage.objects FOR DELETE TO authenticated USING (bucket_id = 'clothes_photos' AND (select auth.uid()::text) = (storage.foldername(name))[1]);