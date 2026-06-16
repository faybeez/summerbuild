CREATE TABLE IF NOT EXISTS public.clothes_tags (
    clothes_id bigint NOT NULL REFERENCES public.clothes(id) ON DELETE CASCADE,
    tag_id bigint NOT NULL REFERENCES public.tags(id) ON DELETE CASCADE,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    PRIMARY KEY (clothes_id, tag_id)
);

ALTER TABLE public.clothes_tags OWNER TO postgres;

COMMENT ON TABLE public.clothes_tags IS 'relationship between clothes and tags';

ALTER TABLE public.clothes_tags ENABLE ROW LEVEL SECURITY;

-- Index

create index idx_clothes_tags_clothes_id
  on public.clothes_tags(clothes_id);

-- Policies

DROP POLICY IF EXISTS clothes_tags_crud_own_data ON public.clothes_tags;

CREATE POLICY clothes_tags_crud_own_data
ON public.clothes_tags
FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1
        FROM public.clothes c
        WHERE c.id = clothes_tags.clothes_id
          AND c.user_id = auth.uid()
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1
        FROM public.clothes c
        WHERE c.id = clothes_tags.clothes_id
          AND c.user_id = auth.uid()
    )
);

GRANT SELECT, INSERT, UPDATE, DELETE ON public.clothes_tags TO authenticated;