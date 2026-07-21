import 'package:flutter/material.dart';

class L10n {
  final Locale locale;

  L10n(this.locale);

  static L10n of(BuildContext context) {
    return Localizations.of<L10n>(context, L10n) ?? L10n(const Locale('es'));
  }

  static const _localizedValues = {
    'es': {
      'app_title': 'Ixeken Live Wallpaper',
      'tab_adjust': 'Ajustar',
      'tab_library': 'Biblioteca',
      'tab_options': 'Ajustes',
      'title_adjust': 'Ajustar Fondo Activo',
      'title_library': 'Biblioteca de Fondos',
      'title_options': 'Ajustes Generales',
      'active_wallpaper': 'Fondo Activo: {}',
      'btn_apply_system': 'ACTIVAR FONDO EN SISTEMA',
      'btn_restore_default': 'RESTAURAR FONDO PREDETERMINADO',
      'search_hint': 'Buscar fondo...',
      'header_wallpapers': 'Fondos de Pantalla',
      'wallpaper_applied': '¡Fondo activado con éxito! Se ve genial.',
      'wallpaper_restored': 'Fondo predeterminado restablecido.',
      'wallpaper_restore_error':
          'Ups, ocurrió un problema al restablecer el fondo.',
      'select_photo_error':
          'Selecciona al menos una foto para armar tu carrusel.',
      'preferences': 'Preferencias',
      'appearance': 'Apariencia',
      'appearance_sub': 'Tema y fuentes',
      'theme_mode': 'Modo del Tema',
      'font_style': 'Estilo de la Fuente',
      'customize_gs_flex': 'Personalizar variaciones de GS Flex',
      'font_opt_system': 'Sistema',
      'app_theme': 'Tema de la Aplicación',
      'theme_sync_system': 'Sincronizado con el sistema',
      'theme_light': 'Tema Claro',
      'theme_dark': 'Tema Oscuro',
      'theme_opt_system': 'Sistema',
      'theme_opt_light': 'Claro',
      'theme_opt_dark': 'Oscuro',
      'sys_permissions': 'Permisos del Sistema',
      'manage_permissions': 'Gestionar Permisos',
      'config_permissions_sub': 'Configurar accesos requeridos y opcionales',
      'about_app': 'Sobre la Aplicación',
      'source_code': 'Código Fuente',
      'source_code_sub': 'Explora el código fuente oficial en GitHub',
      'developed_by': 'Desarrollado por',
      'privacy_policy': 'Aviso de Privacidad',
      'read_privacy': 'Leer declaración de privacidad',
      'privacy_content':
          'Tu privacidad es sagrada para nosotros. Todas tus fotos, videos y configuraciones se procesan y guardan localmente en tu dispositivo. No rastreamos, no recopilamos ni enviamos nada a servidores externos. Tu teléfono, tus reglas.',
      'understood': 'Entendido',
      'perm_manage_title': 'Gestión de Permisos',
      'perm_manage_desc':
          'Ixeken necesita estos accesos para ofrecerte la mejor experiencia visual y mantener tus fondos vivos sin interrupciones.',
      'perm_gallery': 'Acceso a Galería',
      'perm_gallery_sub':
          'Necesario para explorar y elegir tus fotos y videos favoritos.',
      'allow': 'Permitir',
      'perm_optional_service': 'Servicio Opcional',
      'perm_optional_sub': 'Funciones adicionales del fondo',
      'perm_parallax': 'Efecto Parallax',
      'perm_parallax_sub':
          'Utiliza los giroscopios para inclinar el fondo con el movimiento de tu mano.',
      'perm_stability': 'Estabilidad de la App',
      'perm_stability_sub': 'Evita el cierre en segundo plano',
      'perm_battery': 'Optimización de Batería',
      'perm_battery_sub':
          'Evita que el ahorrador del sistema apague las animaciones de fondo.',
      'ignore': 'Ignorar',
      'revoke_settings': 'Revocar Permisos en Ajustes',
      'carousel_day_light': 'Fondos del Carrusel para el Día (Modo Claro)',
      'carousel_night_dark': 'Fondos del Carrusel para la Noche (Modo Oscuro)',
      'carousel_day': 'Fondos del Carrusel para el Día',
      'carousel_night': 'Fondos del Carrusel para la Noche',
      'carousel_general': 'Fondos del Carrusel (General)',
      'opt_dim': 'Oscurecer fondo (Dim)',
      'opt_dim_sub':
          'Sombra sutil para hacer resaltar los iconos de tu pantalla',
      'opt_parallax': 'Efecto Parallax',
      'opt_parallax_sub':
          'Mueve el fondo sutilmente según la inclinación de tu teléfono',
      'opt_random': 'Orden aleatorio (Random)',
      'opt_random_sub': 'Sorpréndete con una foto diferente en cada cambio',
      'opt_sync_theme': 'Sincronizar con Tema del Sistema',
      'opt_sync_theme_sub':
          'Cambia automáticamente entre fotos claras u oscuras según el tema del sistema',
      'opt_day_night': 'Modo Día/Noche (Por Reloj)',
      'opt_day_night_sub':
          'Programa tus fondos favoritos para acompañarte de día y de noche',
      'day_label': 'Día',
      'night_label': 'Noche',
      'opt_change_condition': 'Condición de cambio de foto',
      'change_on_lock': 'Al apagar pantalla',
      'change_on_time': 'Por tiempo',
      'opt_change_interval': 'Intervalo de cambio',
      'seconds': '{} segundos',
      'minute': '1 minuto',
      'minutes': '{} minutos',
      'hour': '1 hora',
      'tetris_style': 'Estilo Visual de Tetris',
      'add': 'Añadir',
      'skipped_files':
          'Se omitieron {} archivo(s) por estar dañados o no ser compatibles.',
      'active': 'Activo',
      'activate': 'Activar',
      'opt_lower_fps': 'Reducir FPS a la mitad',
      'opt_lower_fps_sub':
          'Suaviza el ritmo de cuadro a 30 FPS para cuidar tu batería.',
      'fps_battery_saver_notice':
          'Aviso: Al activar el ahorro de energía de Android, reducimos el ritmo automáticamente para cuidar tu batería.',

      // App Info & Updates
      'back': 'Volver',
      'view_repo': 'Ver repositorio',
      'view_repo_sub': 'Explora el código fuente oficial en GitHub',
      'view_changelog': 'Novedades de la versión',
      'check_updates': 'Buscar actualizaciones',
      'check_update_start': 'Buscar actualización al iniciar',
      'check_update_start_sub':
          'Revisar silenciosamente si hay actualizaciones cada vez que abres la app',
      'created_by': 'Diseñado con dedicación por Ixeken Studios',
      'made_in_mexico': 'Hecho con ❤️ en México',
      'internet_confirm_title': '¿Conectar a Internet?',
      'internet_confirm_desc':
          'Nos conectaremos a GitHub Releases para revisar si hay una nueva versión disponible para ti. ¿Quieres continuar?',
      'btn_cancel': 'Cancelar',
      'btn_proceed': 'Continuar',
      'checking_updates': 'Buscando sorpresas en GitHub...',
      'latest_version_msg':
          '¡Todo al día! Ya tienes la versión más reciente (v{}).',
      'prerelease_version_msg':
          '¡Vienes del futuro! 🚀 Estás usando una versión de prueba o desarrollo más avanzada que las oficiales.',
      'error_check_updates':
          'Ups, no pudimos conectar con GitHub. Revisa tu conexión e intenta de nuevo.',
      'new_version_title': '¡Hay una nueva versión esperándote! ({})',
      'new_version_sub':
          'Una actualización acaba de salir del horno en GitHub Releases.',
      'release_notes': 'Novedades:',
      'btn_download_apk': 'Descargar actualización (.apk)',

      // Lock Screen Settings
      'lock_screen_wallpaper': 'Fondo en Pantalla de Bloqueo',
      'lock_screen_sub':
          'Elige un motor o animación independiente para tu pantalla de bloqueo',
      'same_as_home': 'Usar el mismo de la pantalla de inicio',

      // Appearance
      'font_size': 'Tamaño de Letra',
      'default_label': 'Predeterminado',

      // Customizer & Sub-tabs
      'tab_sub_gallery': 'Galería',
      'tab_sub_options': 'Opciones',
      // Changelog Highlights v1.2.0
      'release_highlights': 'Puntos clave del lanzamiento',
      'cl_overhaul_title': 'Rediseño Completo de la Interfaz',
      'cl_overhaul_desc':
          'Nueva experiencia visual con navegación fluida, tarjetas interactivas y mejor respuesta táctil.',
      'cl_themes_title': 'Temas y Tipografía Personalizables',
      'cl_themes_desc':
          'Elige entre paletas de color únicas (Amoled, Cherry, Elegance, Ixeken) y fuentes como GS Flex, Space Grotesk e Inter.',
      'cl_updates_title': 'Sistema de Actualizaciones GitHub',
      'cl_updates_desc':
          'Comprobación manual y automática de nuevos lanzamientos directamente desde GitHub Releases.',
      'cl_wallpapers_title': 'Colección Ampliada de Fondos',
      'cl_wallpapers_desc':
          'Más motores animados como Aura Holográfica, Lluvia Bokeh, Quantum y Brisa Floral.',
      'cl_performance_title': 'Optimización y Ahorro de Energía',
      'cl_performance_desc':
          'Modo de 30 FPS y reducción automática de consumo con el ahorro de batería de Android.',
      'btn_apply_wallpaper': 'Aplicar fondo de pantalla',

      // Engine Names
      'engine_particles': 'Partículas Flotantes',
      'engine_matrix': 'Lluvia Matrix',
      'engine_plexus': 'Red Plexus',
      'engine_liquid': 'Gradiente Líquido',
      'engine_tetris': 'Juego Tetris',
      'engine_starfield': 'Salto Estelar',
      'engine_vaporwave': 'Retro Vaporwave',
      'engine_conway': 'Juego de la Vida',
      'engine_fluids': 'Enjambre Fluido',
      'engine_carousel': 'Carrusel de Medios',
      'engine_pattern': 'Patrón',
      'engine_floral': 'Brisa Floral',
      'engine_bokeh': 'Lluvia de Luces',
      'engine_quantum': 'Quantum',
      'engine_aura': 'Aura Holográfica',

      // Engine Descriptions
      'desc_particles':
          'Partículas suaves que flotan por la pantalla con un comportamiento fluido y reaccionan al toque del usuario.',
      'desc_matrix':
          'Lluvia de caracteres digitales al estilo Matrix cayendo verticalmente, con velocidad e intensidad aleatorias.',
      'desc_plexus':
          'Nodos interconectados que forman constelaciones flotantes. Las líneas se conectan por proximidad y responden al toque.',
      'desc_liquid':
          'Un fondo dinámico de esferas líquidas en movimiento continuo con gradientes de color suaves y transiciones orgánicas.',
      'desc_tetris':
          'Revive el clásico con un sistema que juega automáticamente. Las piezas buscan huecos inteligentemente para completar líneas y mantener el tablero limpio.',
      'desc_starfield':
          'Vuela a través de un campo de estrellas en tres dimensiones. El efecto reacciona dinámicamente al toque acelerando la velocidad.',
      'desc_vaporwave':
          'Un atardecer retro de los años 80 con una cuadrícula tridimensional en movimiento y un cielo estrellado de neón.',
      'desc_conway':
          'El autómata celular de Conway ejecutándose de forma infinita. Las células nacen y mueren siguiendo reglas simples.',
      'desc_fluids':
          'Un fluido de partículas físicas interactivas que siguen vectores de fuerza dinámicos y responden al cursor táctil.',
      'desc_carousel':
          'Muestra un carrusel de tus fotos y videos preferidos con transiciones suaves y personalizables.',
      'desc_pattern':
          'Mosaico de iconos personalizados desplazándose en cuadrícula diagonal.',
      'desc_floral':
          'Pétalos de flores cayendo y flotando suavemente, balanceados por el viento.',
      'desc_bokeh':
          'Grandes círculos de luces desenfocadas que flotan y se difuminan con elegancia.',
      'desc_quantum':
          'Nodos y líneas de conexiones de energía atraídas magnéticamente por tu dedo.',
      'desc_aura':
          'Burbujas holográficas líquidas de colores que siguen tus toques en pantalla.',
    },
    'en': {
      'app_title': 'Ixeken Live Wallpaper',
      'tab_adjust': 'Adjust',
      'tab_library': 'Library',
      'tab_options': 'Settings',
      'title_adjust': 'Adjust Active Wallpaper',
      'title_library': 'Wallpaper Library',
      'title_options': 'General Settings',
      'active_wallpaper': 'Active Wallpaper: {}',
      'btn_apply_system': 'SET SYSTEM WALLPAPER',
      'btn_restore_default': 'RESTORE DEFAULT WALLPAPER',
      'search_hint': 'Search wallpaper...',
      'header_wallpapers': 'Wallpapers',
      'wallpaper_applied': 'Wallpaper set successfully! Looking fresh.',
      'wallpaper_restored': 'Default wallpaper restored.',
      'wallpaper_restore_error': 'Oops, had trouble restoring the wallpaper.',
      'select_photo_error': 'Pick at least one photo to build your carousel.',
      'preferences': 'Preferences',
      'appearance': 'Appearance',
      'appearance_sub': 'Theme and fonts',
      'theme_mode': 'Theme Mode',
      'font_style': 'Font Style',
      'customize_gs_flex': 'Customize GS Flex Variations',
      'font_opt_system': 'System',
      'app_theme': 'App Theme',
      'theme_sync_system': 'Synchronized with system',
      'theme_light': 'Light Theme',
      'theme_dark': 'Dark Theme',
      'theme_opt_system': 'System',
      'theme_opt_light': 'Light',
      'theme_opt_dark': 'Dark',
      'sys_permissions': 'System Permissions',
      'manage_permissions': 'Manage Permissions',
      'config_permissions_sub': 'Configure required and optional accesses',
      'about_app': 'About App',
      'source_code': 'Source Code',
      'source_code_sub': 'Explore the official source code on GitHub',
      'developed_by': 'Developed by',
      'privacy_policy': 'Privacy Notice',
      'read_privacy': 'Read privacy policy',
      'privacy_content':
          'Your privacy is sacred to us. All imported photos, videos, and settings stay private on your device. We don\'t track, collect, or upload anything to external servers. Your phone, your rules.',
      'understood': 'Understood',
      'perm_manage_title': 'Permission Management',
      'perm_manage_desc':
          'Ixeken needs these permissions to bring your screen to life smoothly and without interruptions.',
      'perm_gallery': 'Gallery Access',
      'perm_gallery_sub':
          'Needed to browse and choose your favorite photos and videos.',
      'allow': 'Allow',
      'perm_optional_service': 'Optional Service',
      'perm_optional_sub': 'Additional wallpaper features',
      'perm_parallax': 'Parallax Effect',
      'perm_parallax_sub':
          'Uses motion sensors to tilt the wallpaper with your hand.',
      'perm_stability': 'App Stability',
      'perm_stability_sub': 'Prevents background closure',
      'perm_battery': 'Battery Optimization',
      'perm_battery_sub':
          'Keeps system battery savers from freezing your wallpaper.',
      'ignore': 'Ignore',
      'revoke_settings': 'Revoke Permissions in Settings',
      'carousel_day_light': 'Carousel Wallpapers for Day (Light Mode)',
      'carousel_night_dark': 'Carousel Wallpapers for Night (Dark Mode)',
      'carousel_day': 'Carousel Wallpapers for Day',
      'carousel_night': 'Carousel Wallpapers for Night',
      'carousel_general': 'Carousel Wallpapers (General)',
      'opt_dim': 'Dim Background',
      'opt_dim_sub': 'Adds a subtle overlay so your home screen icons pop',
      'opt_parallax': 'Parallax Effect',
      'opt_parallax_sub':
          'Shifts the background smoothly as you tilt your phone',
      'opt_random': 'Random Order',
      'opt_random_sub': 'Keep it fresh with a random image on every switch',
      'opt_sync_theme': 'Sync with System Theme',
      'opt_sync_theme_sub':
          'Seamlessly switches light and dark playlists with your system theme',
      'opt_day_night': 'Day/Night Mode (By Clock)',
      'opt_day_night_sub':
          'Schedule your favorite wallpapers for daytime and nightfall',
      'day_label': 'Day',
      'night_label': 'Night',
      'opt_change_condition': 'Photo change condition',
      'change_on_lock': 'When screen is turned off',
      'change_on_time': 'By time',
      'opt_change_interval': 'Change interval',
      'seconds': '{} seconds',
      'minute': '1 minute',
      'minutes': '{} minutes',
      'hour': '1 hour',
      'tetris_style': 'Tetris Visual Style',
      'add': 'Add',
      'skipped_files': 'Skipped {} file(s) that were corrupted or unsupported.',
      'active': 'Active',
      'activate': 'Activate',
      'opt_lower_fps': 'Halve FPS',
      'opt_lower_fps_sub': 'Caps playback at 30 FPS to save battery life.',
      'fps_battery_saver_notice':
          'Notice: When Android\'s Battery Saver mode turns on, we automatically slow down to save power.',

      // App Info & Updates
      'back': 'Back',
      'view_repo': 'View repository',
      'view_repo_sub': 'Explore the official source code on GitHub',
      'view_changelog': 'Release Notes',
      'check_updates': 'Check for updates',
      'check_update_start': 'Check update on start',
      'check_update_start_sub':
          'Quietly check for new versions whenever you open the app',
      'created_by': 'Made by Ixeken Studios',
      'made_in_mexico': 'Made in Mexico',
      'internet_confirm_title': 'Connect to Internet?',
      'internet_confirm_desc':
          'We will check GitHub Releases for new updates. Would you like to proceed?',
      'btn_cancel': 'Cancel',
      'btn_proceed': 'Proceed',
      'checking_updates': 'Checking GitHub for goodies...',
      'latest_version_msg':
          'All up to date! You\'re already running the latest version (v{}).',
      'prerelease_version_msg':
          'Did you come from the future? 🚀 You are running a build ahead of official releases!',
      'error_check_updates':
          'Oops, couldn\'t reach GitHub. Check your internet connection and try again.',
      'new_version_title': 'Fresh update available! ({})',
      'new_version_sub':
          'A brand new release just came fresh out of the oven on GitHub.',
      'release_notes': 'What\'s new:',
      'btn_download_apk': 'Download Update (.apk)',

      // Lock Screen Settings
      'lock_screen_wallpaper': 'Lock Screen Wallpaper',
      'lock_screen_sub':
          'Pick a different wallpaper engine specifically for your lock screen',
      'same_as_home': 'Same as home screen',

      // Appearance
      'font_size': 'Font Size',
      'default_label': 'Default',

      // Customizer & Sub-tabs
      'tab_sub_gallery': 'Gallery',
      'tab_sub_options': 'Settings',
      // Changelog Highlights v1.2.0
      'release_highlights': 'Release Highlights',
      'cl_overhaul_title': 'Complete Interface Overhaul',
      'cl_overhaul_desc':
          'Fresh visual experience featuring smooth navigation, interactive cards, and enhanced touch response.',
      'cl_themes_title': 'Custom Themes & Typography',
      'cl_themes_desc':
          'Choose from curated color palettes (Amoled, Cherry, Elegance, Ixeken) and fonts like GS Flex, Space Grotesk, and Inter.',
      'cl_updates_title': 'GitHub Update System',
      'cl_updates_desc':
          'Manual and automated release checks connected directly to GitHub Releases.',
      'cl_wallpapers_title': 'Expanded Wallpaper Collection',
      'cl_wallpapers_desc':
          'More live engines including Holographic Aura, Bokeh Lights, Quantum, and Floral Breeze.',
      'cl_performance_title': 'Performance & Battery Saver',
      'cl_performance_desc':
          '30 FPS limit toggle and smart battery saver integration to preserve power.',
      'btn_apply_wallpaper': 'Apply wallpaper',

      // Engine Names
      'engine_particles': 'Floating Particles',
      'engine_matrix': 'Matrix Rain',
      'engine_plexus': 'Plexus Network',
      'engine_liquid': 'Liquid Gradient',
      'engine_tetris': 'Tetris Game',
      'engine_starfield': 'Star Jump',
      'engine_vaporwave': 'Retro Vaporwave',
      'engine_conway': 'Game of Life',
      'engine_fluids': 'Fluid Swarm',
      'engine_carousel': 'Media Carousel',
      'engine_pattern': 'Pattern',
      'engine_floral': 'Floral Breeze',
      'engine_bokeh': 'Bokeh Lights',
      'engine_quantum': 'Quantum',
      'engine_aura': 'Holographic Aura',

      // Engine Descriptions
      'desc_particles':
          'Soft particles floating across the screen with a fluid behavior that react to user touch.',
      'desc_matrix':
          'Digital characters rainfall in Matrix style falling vertically with random speed and intensity.',
      'desc_plexus':
          'Interconnected nodes forming floating constellations. Lines connect by proximity and respond to touch.',
      'desc_liquid':
          'A dynamic background of liquid spheres in continuous movement with soft color gradients and organic transitions.',
      'desc_tetris':
          'Relive the classic with a system that plays automatically. The pieces seek gaps intelligently to complete lines and keep the board clean.',
      'desc_starfield':
          'Fly through a three-dimensional star field. The effect reacts dynamically to touch by accelerating speed.',
      'desc_vaporwave':
          'An 80s retro sunset with a moving three-dimensional grid and a starry neon sky.',
      'desc_conway':
          'Conway\'s Game of Life running infinitely. Cells are born and die following simple rules.',
      'desc_fluids':
          'A fluid of interactive physical particles that follow dynamic force vectors and respond to touch.',
      'desc_carousel':
          'Shows a carousel of your favorite photos and videos with smooth and customizable transitions.',
      'desc_pattern': 'Mosaic of custom icons scrolling in a diagonal grid.',
      'desc_floral':
          'Flower petals softly falling and floating, swaying with the wind.',
      'desc_bokeh':
          'Large out-of-focus light circles floating and softly blurring with elegance.',
      'desc_quantum':
          'Energy connection nodes and lines magnetically attracted to your finger.',
      'desc_aura':
          'Colorful liquid holographic bubbles following your screen touches.',
    },
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['es']?[key] ??
        key;
  }

  // Getters for keys
  String get appTitle => get('app_title');
  String get tabAdjust => get('tab_adjust');
  String get tabLibrary => get('tab_library');
  String get tabOptions => get('tab_options');
  String get titleAdjust => get('title_adjust');
  String get titleLibrary => get('title_library');
  String get titleOptions => get('title_options');

  String activeWallpaper(String name) =>
      get('active_wallpaper').replaceAll('{}', name);

  String get btnApplySystem => get('btn_apply_system');
  String get btnRestoreDefault => get('btn_restore_default');
  String get searchHint => get('search_hint');
  String get headerWallpapers => get('header_wallpapers');
  String get wallpaperApplied => get('wallpaper_applied');
  String get wallpaperRestored => get('wallpaper_restored');
  String get wallpaperRestoreError => get('wallpaper_restore_error');
  String get selectPhotoError => get('select_photo_error');
  String get preferences => get('preferences');
  String get appTheme => get('app_theme');
  String get themeSyncSystem => get('theme_sync_system');
  String get themeLight => get('theme_light');
  String get themeDark => get('theme_dark');
  String get themeOptSystem => get('theme_opt_system');
  String get themeOptLight => get('theme_opt_light');
  String get themeOptDark => get('theme_opt_dark');
  String get sysPermissions => get('sys_permissions');
  String get managePermissions => get('manage_permissions');
  String get configPermissionsSub => get('config_permissions_sub');
  String get aboutApp => get('about_app');
  String get sourceCode => get('source_code');
  String get sourceCodeSub => get('source_code_sub');
  String get developedBy => get('developed_by');
  String get privacyPolicy => get('privacy_policy');
  String get readPrivacy => get('read_privacy');
  String get privacyContent => get('privacy_content');
  String get understood => get('understood');

  String get permManageTitle => get('perm_manage_title');
  String get permManageDesc => get('perm_manage_desc');
  String get permGallery => get('perm_gallery');
  String get permGallerySub => get('perm_gallery_sub');
  String get allow => get('allow');
  String get permOptionalService => get('perm_optional_service');
  String get permOptionalSub => get('perm_optional_sub');
  String get permParallax => get('perm_parallax');
  String get permParallaxSub => get('perm_parallax_sub');
  String get permStability => get('perm_stability');
  String get permStabilitySub => get('perm_stability_sub');
  String get permBattery => get('perm_battery');
  String get permBatterySub => get('perm_battery_sub');
  String get ignore => get('ignore');
  String get revokeSettings => get('revoke_settings');

  String get carouselDayLight => get('carousel_day_light');
  String get carouselNightDark => get('carousel_night_dark');
  String get carouselDay => get('carousel_day');
  String get carouselNight => get('carousel_night');
  String get carouselGeneral => get('carousel_general');
  String get optDim => get('opt_dim');
  String get optDimSub => get('opt_dim_sub');
  String get optParallax => get('opt_parallax');
  String get optParallaxSub => get('opt_parallax_sub');
  String get optRandom => get('opt_random');
  String get optRandomSub => get('opt_random_sub');
  String get optSyncTheme => get('opt_sync_theme');
  String get optSyncThemeSub => get('opt_sync_theme_sub');
  String get optDayNight => get('opt_day_night');
  String get optDayNightSub => get('opt_day_night_sub');
  String get dayLabel => get('day_label');
  String get nightLabel => get('night_label');
  String get optChangeCondition => get('opt_change_condition');
  String get changeOnLock => get('change_on_lock');
  String get changeOnTime => get('change_on_time');
  String get optChangeInterval => get('opt_change_interval');

  String formatSeconds(int val) =>
      get('seconds').replaceAll('{}', val.toString());
  String get formatMinute => get('minute');
  String formatMinutes(int val) =>
      get('minutes').replaceAll('{}', val.toString());
  String get formatHour => get('hour');

  String get tetrisStyle => get('tetris_style');
  String get add => get('add');
  String get active => get('active');
  String get activate => get('activate');
  String get appearance => get('appearance');
  String get appearanceSub => get('appearance_sub');
  String get themeModeTitle => get('theme_mode');
  String get fontStyleTitle => get('font_style');
  String get customizeGsFlex => get('customize_gs_flex');
  String get fontOptSystem => get('font_opt_system');
  String get optLowerFps => get('opt_lower_fps');
  String get optLowerFpsSub => get('opt_lower_fps_sub');
  String get fpsBatterySaverNotice => get('fps_battery_saver_notice');

  // App Info & Updates
  String get back => get('back');
  String get viewRepo => get('view_repo');
  String get viewRepoSub => get('view_repo_sub');
  String get viewChangelog => get('view_changelog');
  String get checkUpdates => get('check_updates');
  String get checkUpdateStart => get('check_update_start');
  String get checkUpdateStartSub => get('check_update_start_sub');
  String get createdBy => get('created_by');
  String get madeInMexico => get('made_in_mexico');
  String get internetConfirmTitle => get('internet_confirm_title');
  String get internetConfirmDesc => get('internet_confirm_desc');
  String get btnCancel => get('btn_cancel');
  String get btnProceed => get('btn_proceed');
  String get checkingUpdates => get('checking_updates');
  String latestVersionMsg(String v) =>
      get('latest_version_msg').replaceAll('{}', v);
  String get prereleaseVersionMsg => get('prerelease_version_msg');
  String get errorCheckUpdates => get('error_check_updates');
  String newVersionTitle(String v) =>
      get('new_version_title').replaceAll('{}', v);
  String get newVersionSub => get('new_version_sub');
  String get releaseNotes => get('release_notes');
  String get btnDownloadApk => get('btn_download_apk');

  // Lock Screen Settings
  String get lockScreenWallpaper => get('lock_screen_wallpaper');
  String get lockScreenSub => get('lock_screen_sub');
  String get sameAsHome => get('same_as_home');

  // Appearance
  String get fontSize => get('font_size');
  String get defaultLabel => get('default_label');

  // Customizer & Sub-tabs
  String get tabSubGallery => get('tab_sub_gallery');
  String get tabSubOptions => get('tab_sub_options');
  String get btnApplyWallpaper => get('btn_apply_wallpaper');

  // Changelog Highlights v1.2.0
  String get releaseHighlights => get('release_highlights');
  String get clOverhaulTitle => get('cl_overhaul_title');
  String get clOverhaulDesc => get('cl_overhaul_desc');
  String get clThemesTitle => get('cl_themes_title');
  String get clThemesDesc => get('cl_themes_desc');
  String get clUpdatesTitle => get('cl_updates_title');
  String get clUpdatesDesc => get('cl_updates_desc');
  String get clWallpapersTitle => get('cl_wallpapers_title');
  String get clWallpapersDesc => get('cl_wallpapers_desc');
  String get clPerformanceTitle => get('cl_performance_title');
  String get clPerformanceDesc => get('cl_performance_desc');

  // Engine Names
  String get engineParticles => get('engine_particles');
  String get engineMatrix => get('engine_matrix');
  String get enginePlexus => get('engine_plexus');
  String get engineLiquid => get('engine_liquid');
  String get engineTetris => get('engine_tetris');
  String get engineStarfield => get('engine_starfield');
  String get engineVaporwave => get('engine_vaporwave');
  String get engineConway => get('engine_conway');
  String get engineFluids => get('engine_fluids');
  String get engineCarousel => get('engine_carousel');
  String get enginePattern => get('engine_pattern');
  String get engineFloral => get('engine_floral');
  String get engineBokeh => get('engine_bokeh');
  String get engineQuantum => get('engine_quantum');
  String get engineAura => get('engine_aura');

  // Engine Descriptions
  String get descParticles => get('desc_particles');
  String get descMatrix => get('desc_matrix');
  String get descPlexus => get('desc_plexus');
  String get descLiquid => get('desc_liquid');
  String get descTetris => get('desc_tetris');
  String get descStarfield => get('desc_starfield');
  String get descVaporwave => get('desc_vaporwave');
  String get descConway => get('desc_conway');
  String get descFluids => get('desc_fluids');
  String get descCarousel => get('desc_carousel');
  String get descPattern => get('desc_pattern');
  String get descFloral => get('desc_floral');
  String get descBokeh => get('desc_bokeh');
  String get descQuantum => get('desc_quantum');
  String get descAura => get('desc_aura');

  String skippedFiles(int count) =>
      get('skipped_files').replaceAll('{}', count.toString());
}

class L10nDelegate extends LocalizationsDelegate<L10n> {
  const L10nDelegate();

  @override
  bool isSupported(Locale locale) => ['es', 'en'].contains(locale.languageCode);

  @override
  Future<L10n> load(Locale locale) async {
    return L10n(locale);
  }

  @override
  bool shouldReload(L10nDelegate old) => false;
}
