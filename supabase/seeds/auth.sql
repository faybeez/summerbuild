
INSERT INTO "auth"."flow_state" ("id", "user_id", "auth_code", "code_challenge_method", "code_challenge", "provider_type", "provider_access_token", "provider_refresh_token", "created_at", "updated_at", "authentication_method", "auth_code_issued_at", "invite_token", "referrer", "oauth_client_state_id", "linking_target_id", "email_optional") VALUES
	('2ed394a3-68f4-4b50-a05c-2719837649a3', '704ff5e0-11bb-4c96-a13f-cf16604107d0', 'a577a27f-8153-4cb0-9f0e-00f07f7ee7d4', 's256', 'v-nO27fSIvPSutZotLmP9txl-PkiKpYhh-EjWabCdm0', 'email', '', '', '2026-05-26 14:07:13.72313+00', '2026-05-26 14:07:33.49978+00', 'email/signup', '2026-05-26 14:07:33.499713+00', NULL, NULL, NULL, NULL, false);

INSERT INTO "auth"."users" ("instance_id", "id", "aud", "role", "email", "encrypted_password", "email_confirmed_at", "invited_at", "confirmation_token", "confirmation_sent_at", "recovery_token", "recovery_sent_at", "email_change_token_new", "email_change", "email_change_sent_at", "last_sign_in_at", "raw_app_meta_data", "raw_user_meta_data", "is_super_admin", "created_at", "updated_at", "phone", "phone_confirmed_at", "phone_change", "phone_change_token", "phone_change_sent_at", "email_change_token_current", "email_change_confirm_status", "banned_until", "reauthentication_token", "reauthentication_sent_at", "is_sso_user", "deleted_at", "is_anonymous") VALUES
	('00000000-0000-0000-0000-000000000000', '704ff5e0-11bb-4c96-a13f-cf16604107d0', 'authenticated', 'authenticated', 'faybeata.s3@gmail.com', '$2a$10$d71bG6rGpZK4ohZ3mRxY5eN4VSNf8gZVENd.om5nPyl1X6tnRAYWa', '2026-05-26 14:07:33.484206+00', NULL, '', '2026-05-26 14:07:13.730995+00', '', NULL, '', '', NULL, '2026-05-26 14:20:57.380619+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "704ff5e0-11bb-4c96-a13f-cf16604107d0", "email": "faybeata.s3@gmail.com", "email_verified": true, "phone_verified": false}', NULL, '2026-05-26 14:07:13.698065+00', '2026-05-26 14:20:57.410812+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false);

INSERT INTO "auth"."identities" ("provider_id", "user_id", "identity_data", "provider", "last_sign_in_at", "created_at", "updated_at", "id") VALUES
	('704ff5e0-11bb-4c96-a13f-cf16604107d0', '704ff5e0-11bb-4c96-a13f-cf16604107d0', '{"sub": "704ff5e0-11bb-4c96-a13f-cf16604107d0", "email": "faybeata.s3@gmail.com", "email_verified": true, "phone_verified": false}', 'email', '2026-05-26 14:07:13.717278+00', '2026-05-26 14:07:13.717339+00', '2026-05-26 14:07:13.717339+00', '03f85448-64ed-4fc1-afc0-550eddf5964c');

INSERT INTO "auth"."sessions" ("id", "user_id", "created_at", "updated_at", "factor_id", "aal", "not_after", "refreshed_at", "user_agent", "ip", "tag", "oauth_client_id", "refresh_token_hmac_key", "refresh_token_counter", "scopes") VALUES
	('e01b8f20-dcfc-4b76-a48f-41e352f79f1c', '704ff5e0-11bb-4c96-a13f-cf16604107d0', '2026-05-26 14:20:57.383315+00', '2026-05-26 14:20:57.383315+00', NULL, 'aal1', NULL, NULL, 'Dart/3.12 (dart:io)', '155.69.184.21', NULL, NULL, NULL, NULL, NULL);

INSERT INTO "auth"."mfa_amr_claims" ("session_id", "created_at", "updated_at", "authentication_method", "id") VALUES
	('e01b8f20-dcfc-4b76-a48f-41e352f79f1c', '2026-05-26 14:20:57.412662+00', '2026-05-26 14:20:57.412662+00', 'password', '066eeb21-efc8-4b87-bf7f-dfd052606c7f');

INSERT INTO "auth"."refresh_tokens" ("instance_id", "id", "token", "user_id", "revoked", "created_at", "updated_at", "parent", "session_id") VALUES
	('00000000-0000-0000-0000-000000000000', 1, '4xh733u5q3we', '704ff5e0-11bb-4c96-a13f-cf16604107d0', false, '2026-05-26 14:20:57.402213+00', '2026-05-26 14:20:57.402213+00', NULL, 'e01b8f20-dcfc-4b76-a48f-41e352f79f1c');

SELECT pg_catalog.setval('"auth"."refresh_tokens_id_seq"', 1, true);

SELECT pg_catalog.setval('"public"."clothes_id_seq"', 1, false);

SELECT pg_catalog.setval('"public"."tags_id_seq"', 6, true);