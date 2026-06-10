INSERT INTO "storage"."buckets" ("id", "name", "owner", "created_at", "updated_at", "public", "avif_autodetection", "file_size_limit", "allowed_mime_types", "owner_id", "type") VALUES
	('clothes_photos', 'clothes_photos', NULL, '2026-05-28 15:13:56.272467+00', '2026-05-28 15:13:56.272467+00', false, false, 1048576, NULL, NULL, 'STANDARD');

CREATE POLICY "Give users access to own folder 14u3azc_0" ON storage.objects FOR SELECT TO authenticated USING (bucket_id = 'clothes_photos' AND (select auth.uid()::text) = (storage.foldername(name))[1]);

CREATE POLICY "Give users access to own folder 14u3azc_1" ON storage.objects FOR INSERT TO authenticated WITH CHECK (bucket_id = 'clothes_photos' AND (select auth.uid()::text) = (storage.foldername(name))[1]);

CREATE POLICY "Give users access to own folder 14u3azc_2" ON storage.objects FOR UPDATE TO authenticated USING (bucket_id = 'clothes_photos' AND (select auth.uid()::text) = (storage.foldername(name))[1]);

CREATE POLICY "Give users access to own folder 14u3azc_3" ON storage.objects FOR DELETE TO authenticated USING (bucket_id = 'clothes_photos' AND (select auth.uid()::text) = (storage.foldername(name))[1]);