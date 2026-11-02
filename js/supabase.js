// Supabase client setup
// Replace the two placeholders below with your real values.
// Find them at: Supabase Dashboard > Project Settings > API

var SUPABASE_URL = 'https://ygoxbstbflqakxsemeyb.supabase.co';
var SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inlnb3hic3RiZmxxYWt4c2VtZXliIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTM2MjcxNzksImV4cCI6MjEwOTIwMzE3OX0.mSHNFM1XwXSPoonjsSk_CZdQzmtBes0La6G6JqkbQqo';

// create the client - all other js files use the global 'db'
var db = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
