-- Add Category values
INSERT INTO public.tags (tag_type, tag_value, tag_display_name)
SELECT tag_type, tag_value, tag_display_name
FROM (
    VALUES
        ('CATEGORY', 'TOPS', 'Tops'),
        ('CATEGORY', 'PANTS', 'Pants'),
        ('CATEGORY', 'SHOES', 'Shoes'),
        ('CATEGORY', 'OUTERWEAR', 'Outerwear'),
        ('CATEGORY', 'DRESSES', 'Dresses'),
        ('CATEGORY', 'ACCESSORIES', 'Accessories'),
        ('CATEGORY', 'SHORTS', 'Shorts'),
        ('CATEGORY', 'SKIRTS', 'Skirts'),
        ('CATEGORY', 'SUITS', 'Suits'),
        ('CATEGORY', 'ACTIVEWEAR', 'Activewear'),
        ('CATEGORY', 'SLEEPWEAR', 'Sleepwear'),
        ('CATEGORY', 'SWIMWEAR', 'Swimwear')
) AS new_tags(tag_type, tag_value, tag_display_name)
WHERE NOT EXISTS (
    SELECT 1
    FROM public.tags t
    WHERE t.tag_type = new_tags.tag_type
      AND t.tag_value = new_tags.tag_value
);


-- Add Occasion values
INSERT INTO public.tags (tag_type, tag_value, tag_display_name)
SELECT tag_type, tag_value, tag_display_name
FROM (
    VALUES
        ('OCCASION', 'CASUAL', 'Casual'),
        ('OCCASION', 'BUSINESS', 'Business'),
        ('OCCASION', 'FORMAL', 'Formal'),
        ('OCCASION', 'SMARTCASUAL', 'Smart Casual'),
        ('OCCASION', 'PARTY', 'Party'),
        ('OCCASION', 'DATE', 'Date'),
        ('OCCASION', 'SCHOOL', 'School'),
        ('OCCASION', 'SPORTS', 'Sports'),
        ('OCCASION', 'OUTDOOR', 'Outdoor'),
        ('OCCASION', 'BEACH', 'Beach'),
        ('OCCASION', 'HOME', 'Home'),
        ('OCCASION', 'LOUNGE', 'Loungewear'),
        ('OCCASION', 'SLEEP', 'Sleepwear')
) AS new_tags(tag_type, tag_value, tag_display_name)
WHERE NOT EXISTS (
    SELECT 1
    FROM public.tags t
    WHERE t.tag_type = new_tags.tag_type
      AND t.tag_value = new_tags.tag_value
);


-- Add Weather values
INSERT INTO public.tags (tag_type, tag_value, tag_display_name)
SELECT tag_type, tag_value, tag_display_name
FROM (
    VALUES
        ('WEATHER', 'HOT', 'Hot Weather'),
        ('WEATHER', 'COLD', 'Cold Weather'),
        ('WEATHER', 'SNOW', 'Snowy Weather'),
        ('WEATHER', 'RAIN', 'Rainy Weather'),
        ('WEATHER', 'WIND', 'Windy Weather'),
        ('WEATHER', 'HUMID', 'Humid Weather'),
        ('WEATHER', 'DRY', 'Dry Weather')
) AS new_tags(tag_type, tag_value, tag_display_name)
WHERE NOT EXISTS (
    SELECT 1
    FROM public.tags t
    WHERE t.tag_type = new_tags.tag_type
      AND t.tag_value = new_tags.tag_value
);


-- Add Color values
INSERT INTO public.tags (tag_type, tag_value, tag_display_name)
SELECT tag_type, tag_value, tag_display_name
FROM (
    VALUES
        ('COLOR', 'BLACK', 'Black'),
        ('COLOR', 'WHITE', 'White'),
        ('COLOR', 'GRAY', 'Gray'),
        ('COLOR', 'RED', 'Red'),
        ('COLOR', 'BLUE', 'Blue'),
        ('COLOR', 'GREEN', 'Green'),
        ('COLOR', 'YELLOW', 'Yellow'),
        ('COLOR', 'ORANGE', 'Orange'),
        ('COLOR', 'PURPLE', 'Purple'),
        ('COLOR', 'PINK', 'Pink'),
        ('COLOR', 'BROWN', 'Brown'),
        ('COLOR', 'BEIGE', 'Beige'),
        ('COLOR', 'CREAM', 'Cream'),
        ('COLOR', 'NAVY', 'Navy'),
        ('COLOR', 'GOLD', 'Gold'),
        ('COLOR', 'SILVER', 'Silver')
) AS new_tags(tag_type, tag_value, tag_display_name)
WHERE NOT EXISTS (
    SELECT 1
    FROM public.tags t
    WHERE t.tag_type = new_tags.tag_type
      AND t.tag_value = new_tags.tag_value
);