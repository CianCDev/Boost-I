-- Migración: Desactivar trigger de pgcrypto para telegram_config
-- Motivo: Error 42501 permission denied for function _crypto_aead_det_noncegen
-- Solución: Encriptación del lado de la app (Dart) usando AES-256-CBC

-- 1. Eliminar el trigger que intenta encriptar con pgcrypto
DROP TRIGGER IF EXISTS telegram_config_encrypt_token_trg ON public.telegram_config;

-- 2. Eliminar las funciones de pgcrypto que ya no se necesitan
-- (Opcional: solo si estás seguro de que no se usan en otro lugar)
-- DROP FUNCTION IF EXISTS public.telegram_config_encrypt_token();
-- DROP FUNCTION IF EXISTS public.encrypt_telegram_token(text);
-- DROP FUNCTION IF EXISTS public.decrypt_telegram_token(text);
-- DROP FUNCTION IF EXISTS public.get_telegram_key();

-- 3. Comentario para documentar el cambio
COMMENT ON TABLE public.telegram_config IS 
  'Los tokens de Telegram se encriptan del lado de la app (Dart AES-256-CBC) antes de guardarse. El trigger de pgcrypto fue desactivado por permisos insuficientes.';
