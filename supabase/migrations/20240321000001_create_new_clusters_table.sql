-- Drop existing table if it exists
DROP TABLE IF EXISTS clusters;

-- Create clusters table with correct column names
CREATE TABLE clusters (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT,
    latitude FLOAT8,
    longitude FLOAT8,
    size INT4,
    radius FLOAT8,
    priority FLOAT8,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
); 