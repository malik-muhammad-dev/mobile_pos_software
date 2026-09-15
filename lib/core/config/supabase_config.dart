/// Supabase project connection details.
///
/// The anon/publishable key below is safe to ship inside the app — it's
/// meant to be public, and every table it can touch is locked down by Row
/// Level Security on the Supabase side (see phase1_subscription_schema.sql).
/// The separate service_role/secret key is NOT here and must never be —
/// that one bypasses RLS entirely and only ever belongs in the future
/// admin dashboard, run somewhere private.
class SupabaseConfig {
  SupabaseConfig._();

  static const String url = 'https://egtpdevskzoadphmhqkv.supabase.co';
  static const String anonKey = 'sb_publishable_xwfs-qhAE8kS2wMJ79tNpQ_JQF_wU9o';
}