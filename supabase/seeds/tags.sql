-- Add missing Clothes Type values
INSERT INTO public.tags (tag_type, tag_name)
SELECT tag_type, tag_name
FROM (
    VALUES
        ('Clothes Type', 'Tops'),
        ('Clothes Type', 'Pants'),
        ('Clothes Type', 'Shoes'),
        ('Clothes Type', 'Outerwear'),
        ('Clothes Type', 'Dresses'),
        ('Clothes Type', 'Accessories'),
        ('Clothes Type', 'Shorts'),
        ('Clothes Type', 'Skirts'),
        ('Clothes Type', 'Suits'),
        ('Clothes Type', 'Activewear'),
        ('Clothes Type', 'Sleepwear'),
        ('Clothes Type', 'Swimwear')
) AS new_tags(tag_type, tag_name)
WHERE NOT EXISTS (
    SELECT 1
    FROM public.tags t
    WHERE t.tag_type = new_tags.tag_type
      AND t.tag_name = new_tags.tag_name
);


-- Add Occasion values
INSERT INTO public.tags (tag_type, tag_name)
SELECT tag_type, tag_name
FROM (
    VALUES
        ('Occasion', 'Casual'),
        ('Occasion', 'Business'),
        ('Occasion', 'Formal'),
        ('Occasion', 'Smart Casual'),
        ('Occasion', 'Party'),
        ('Occasion', 'Date'),
        ('Occasion', 'School'),
        ('Occasion', 'Sports'),
        ('Occasion', 'Outdoor'),
        ('Occasion', 'Beach'),
        ('Occasion', 'Home'),
        ('Occasion', 'Loungewear'),
        ('Occasion', 'Sleepwear')
) AS new_tags(tag_type, tag_name)
WHERE NOT EXISTS (
    SELECT 1
    FROM public.tags t
    WHERE t.tag_type = new_tags.tag_type
      AND t.tag_name = new_tags.tag_name
);

-- Add Weather values
INSERT INTO public.tags (tag_type, tag_name)
SELECT tag_type, tag_name
FROM (
    VALUES
        ('Weather Fit', 'Hot Weather'),
        ('Weather Fit', 'Cold Weather'),
		('Weather Fit', 'Snowy Weather'),
        ('Weather Fit', 'Rainy Weather'),
        ('Weather Fit', 'Windy Weather'),
        ('Weather Fit', 'Humid Weather'),
        ('Weather Fit', 'Dry Weather')
) AS new_tags(tag_type, tag_name)
WHERE NOT EXISTS (
    SELECT 1
    FROM public.tags t
    WHERE t.tag_type = new_tags.tag_type
      AND t.tag_name = new_tags.tag_name
);

-- Add Colors values
INSERT INTO public.tags (tag_type, tag_name)
SELECT tag_type, tag_name
FROM (
    VALUES
        ('Colors', 'Black'),
        ('Colors', 'White'),
        ('Colors', 'Gray'),
        ('Colors', 'Red'),
        ('Colors', 'Blue'),
        ('Colors', 'Green'),
        ('Colors', 'Yellow'),
        ('Colors', 'Orange'),
        ('Colors', 'Purple'),
        ('Colors', 'Pink'),
        ('Colors', 'Brown'),
        ('Colors', 'Beige'),
        ('Colors', 'Cream'),
        ('Colors', 'Navy'),
        ('Colors', 'Gold'),
        ('Colors', 'Silver')
) AS new_tags(tag_type, tag_name)
WHERE NOT EXISTS (
    SELECT 1
    FROM public.tags t
    WHERE t.tag_type = new_tags.tag_type
      AND t.tag_name = new_tags.tag_name
);