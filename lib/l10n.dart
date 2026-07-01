import 'package:flutter/material.dart';

class L10n {
  final Locale locale;

  L10n(this.locale);

  static L10n of(BuildContext context) {
    return Localizations.of<L10n>(context, L10n) ?? L10n(const Locale('es'));
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'es': {
      'app_title': 'Ixeken Live Wallpaper',
      'tab_adjust': 'Ajustar',
      'tab_library': 'Biblioteca',
      'tab_options': 'Opciones',
      'title_adjust': 'Ajustar Fondo Activo',
      'title_library': 'Biblioteca de Fondos',
      'title_options': 'Ajustes Generales',
      'active_wallpaper': 'Fondo Activo: {}',
      'btn_apply_system': 'ACTIVAR FONDO EN SISTEMA',
      'btn_restore_default': 'RESTAURAR FONDO PREDETERMINADO',
      'search_hint': 'Buscar fondo...',
      'header_wallpapers': 'Fondos de Pantalla',
      'wallpaper_applied': 'Fondo aplicado correctamente',
      'wallpaper_restored': 'Fondo predeterminado restablecido',
      'wallpaper_restore_error': 'Error al restablecer fondo',
      'select_photo_error': 'Selecciona al menos una foto para el carrusel',
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
      'source_code_sub': 'Ver repositorio oficial en GitHub',
      'developed_by': 'Desarrollado por',
      'privacy_policy': 'Aviso de Privacidad',
      'read_privacy': 'Leer declaración de privacidad',
      'privacy_content': 'Esta aplicación respeta tu privacidad por completo. Todos tus archivos multimedia importados se procesan y almacenan localmente dentro del almacenamiento interno privado de tu dispositivo. No recopilamos, transmitimos ni compartimos ninguna información personal ni archivos del usuario con servidores externos.',
      'understood': 'Entendido',
      'perm_manage_title': 'Gestión de Permisos',
      'perm_manage_desc': 'Ixeken necesita estos permisos para funcionar correctamente y ofrecerte la mejor experiencia visual.',
      'perm_gallery': 'Acceso a Galería',
      'perm_gallery_sub': 'Requerido para elegir tus fondos.',
      'allow': 'Permitir',
      'perm_optional_service': 'Servicio Opcional',
      'perm_optional_sub': 'Funciones adicionales del fondo',
      'perm_parallax': 'Efecto Parallax',
      'perm_parallax_sub': 'Usa los sensores para rotar el fondo.',
      'perm_stability': 'Estabilidad de la App',
      'perm_stability_sub': 'Evita el cierre en segundo plano',
      'perm_battery': 'Optimización de Batería',
      'perm_battery_sub': 'Impide que el sistema cierre el fondo.',
      'ignore': 'Ignorar',
      'revoke_settings': 'Revocar Permisos en Ajustes',
      'carousel_day_light': 'Fondos del Carrusel para el Día (Modo Claro)',
      'carousel_night_dark': 'Fondos del Carrusel para la Noche (Modo Oscuro)',
      'carousel_day': 'Fondos del Carrusel para el Día',
      'carousel_night': 'Fondos del Carrusel para la Noche',
      'carousel_general': 'Fondos del Carrusel (General)',
      'opt_dim': 'Oscurecer fondo (Dim)',
      'opt_dim_sub': 'Para resaltar los iconos del sistema',
      'opt_parallax': 'Efecto Parallax',
      'opt_parallax_sub': 'Desplaza el fondo dinámicamente con la inclinación del teléfono',
      'opt_random': 'Orden aleatorio (Random)',
      'opt_random_sub': 'Muestra las imágenes sin un orden fijo',
      'opt_sync_theme': 'Sincronizar con Tema del Sistema',
      'opt_sync_theme_sub': 'Alterna las listas de reproducción Día/Noche en tiempo real',
      'opt_day_night': 'Modo Día/Noche (Por Reloj)',
      'opt_day_night_sub': 'Usa fondos según las horas configuradas',
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
      'skipped_files': 'Se omitieron {} archivo(s) por estar dañados o ser incompatibles.',
      'active': 'Activo',
      'activate': 'Activar',
      'opt_lower_fps': 'Reducir FPS a la mitad',
      'opt_lower_fps_sub': 'Mejora el rendimiento y reduce el uso de batería.',
      'fps_battery_saver_notice': 'Aviso: El límite de FPS se activa automáticamente con el ahorro de batería de Android.',
      
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
      'engine_voronoi': 'Constelación Voronoi',
      'engine_waveforms': 'Osciloscopio Synthwave',
      'engine_boids': 'Simulación de Boids',
      'engine_julia': 'Fractal de Julia',
      'engine_sakura': 'Sakura Zen',
      'engine_pachinko': 'Pachinko de Neón',
      'engine_kaleidoscope': 'Caleidoscopio Giroscópico',
      
      // Engine Descriptions
      'desc_particles': 'Partículas suaves que flotan por la pantalla con un comportamiento fluido y reaccionan al toque del usuario.',
      'desc_matrix': 'Lluvia de caracteres digitales al estilo Matrix cayendo verticalmente, con velocidad e intensidad aleatorias.',
      'desc_plexus': 'Nodos interconectados que forman constelaciones flotantes. Las líneas se conectan por proximidad y responden al toque.',
      'desc_liquid': 'Un fondo dinámico de esferas líquidas en movimiento continuo con gradientes de color suaves y transiciones orgánicas.',
      'desc_tetris': 'Relive el clásico con un sistema que juega automáticamente. Las piezas buscan huecos de forma inteligente para completar líneas.',
      'desc_starfield': 'Vuela a través de un campo de estrellas tridimensional. El efecto reacciona dinámicamente al toque acelerando la velocidad.',
      'desc_vaporwave': 'Un atardecer retro de los 80 con una rejilla tridimensional en movimiento y un cielo estrellado de neón.',
      'desc_conway': 'El Juego de la Vida de Conway ejecutándose infinitamente. Las células nacen y mueren siguiendo reglas simples.',
      'desc_fluids': 'Un fluido de partículas físicas interactivas que siguen vectores de fuerza dinámicos y responden al tacto.',
      'desc_carousel': 'Muestra un carrusel con tus fotos y videos favoritos con transiciones suaves y personalizables.',
      'desc_voronoi': 'Malla geométrica dinámica que calcula diagramas de Voronoi y celdas de color interactivas al tacto.',
      'desc_waveforms': 'Ondas senoidales y cosenoidales complejas que oscilan y se entrelazan de forma tridimensional sobre neón.',
      'desc_boids': 'Simulación física de comportamiento colectivo de bandadas de aves o peces que evitan obstáculos y siguen al dedo.',
      'desc_julia': 'Exploración matemática interactiva del conjunto fractal de Julia mutable en tiempo real con arrastre táctil.',
      'desc_sakura': 'Árboles de cerezo generados procedimentalmente con caída física de pétalos mecidos por el viento del giroscopio.',
      'desc_pachinko': 'Caída y colisión física 2D de canicas de luz neón sobre postes geométricos fijos con vibraciones hápticas.',
      'desc_kaleidoscope': 'Formas geométricas reflejadas en secciones radiales simétricas virtuales que giran con el giroscopio.',
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
      'wallpaper_applied': 'Wallpaper applied successfully',
      'wallpaper_restored': 'Default wallpaper restored',
      'wallpaper_restore_error': 'Error restoring wallpaper',
      'select_photo_error': 'Select at least one photo for the carousel',
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
      'source_code_sub': 'View official repository on GitHub',
      'developed_by': 'Developed by',
      'privacy_policy': 'Privacy Notice',
      'read_privacy': 'Read privacy policy',
      'privacy_content': 'This application respects your privacy completely. All your imported media files are processed and stored locally within your device\'s private internal storage. We do not collect, transmit, or share any personal information or user files with external servers.',
      'understood': 'Understood',
      'perm_manage_title': 'Permission Management',
      'perm_manage_desc': 'Ixeken needs these permissions to work properly and offer you the best visual experience.',
      'perm_gallery': 'Gallery Access',
      'perm_gallery_sub': 'Required to choose your wallpapers.',
      'allow': 'Allow',
      'perm_optional_service': 'Optional Service',
      'perm_optional_sub': 'Additional wallpaper features',
      'perm_parallax': 'Parallax Effect',
      'perm_parallax_sub': 'Uses sensors to rotate the wallpaper.',
      'perm_stability': 'App Stability',
      'perm_stability_sub': 'Prevents background closure',
      'perm_battery': 'Battery Optimization',
      'perm_battery_sub': 'Prevents the system from closing the wallpaper.',
      'ignore': 'Ignore',
      'revoke_settings': 'Revoke Permissions in Settings',
      'carousel_day_light': 'Carousel Wallpapers for Day (Light Mode)',
      'carousel_night_dark': 'Carousel Wallpapers for Night (Dark Mode)',
      'carousel_day': 'Carousel Wallpapers for Day',
      'carousel_night': 'Carousel Wallpapers for Night',
      'carousel_general': 'Carousel Wallpapers (General)',
      'opt_dim': 'Dim Background',
      'opt_dim_sub': 'To highlight system icons',
      'opt_parallax': 'Parallax Effect',
      'opt_parallax_sub': 'Displaces the background dynamically with phone tilt',
      'opt_random': 'Random Order',
      'opt_random_sub': 'Displays images without a fixed order',
      'opt_sync_theme': 'Sync with System Theme',
      'opt_sync_theme_sub': 'Switches Day/Night playlists in real time',
      'opt_day_night': 'Day/Night Mode (By Clock)',
      'opt_day_night_sub': 'Uses wallpapers based on scheduled hours',
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
      'skipped_files': 'Skipped {} file(s) due to corruption or incompatibility.',
      'active': 'Active',
      'activate': 'Activate',
      'opt_lower_fps': 'Halve FPS',
      'opt_lower_fps_sub': 'Improves performance and reduces battery usage.',
      'fps_battery_saver_notice': 'Notice: FPS limit is automatically enabled when Android\'s Battery Saver mode active.',
      
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
      'engine_voronoi': 'Voronoi Constellation',
      'engine_waveforms': 'Synthwave Oscilloscope',
      'engine_boids': 'Boids Flocking',
      'engine_julia': 'Julia Set Fractal',
      'engine_sakura': 'Sakura Zen',
      'engine_pachinko': 'Neon Pachinko',
      'engine_kaleidoscope': 'Gyroscopic Kaleidoscope',
      
      // Engine Descriptions
      'desc_particles': 'Soft particles floating across the screen with a fluid behavior that react to user touch.',
      'desc_matrix': 'Digital characters rainfall in Matrix style falling vertically with random speed and intensity.',
      'desc_plexus': 'Interconnected nodes forming floating constellations. Lines connect by proximity and respond to touch.',
      'desc_liquid': 'A dynamic background of liquid spheres in continuous movement with soft color gradients and organic transitions.',
      'desc_tetris': 'Relive the classic with a system that plays automatically. The pieces seek gaps intelligently to complete lines and keep the board clean.',
      'desc_starfield': 'Fly through a three-dimensional star field. The effect reacts dynamically to touch by accelerating speed.',
      'desc_vaporwave': 'An 80s retro sunset with a moving three-dimensional grid and a starry neon sky.',
      'desc_conway': 'Conway\'s Game of Life running infinitely. Cells are born and die following simple rules.',
      'desc_fluids': 'A fluid of interactive physical particles that follow dynamic force vectors and respond to touch.',
      'desc_carousel': 'Shows a carousel of your favorite photos and videos with smooth and customizable transitions.',
      'desc_voronoi': 'Dynamic geometric mesh calculating Voronoi diagrams and interactive colored cells on touch.',
      'desc_waveforms': 'Complex sine and cosine waves oscillating and interlocking in 3D neon space.',
      'desc_boids': 'Physical flocking simulation of birds or fish that avoid obstacles and follow your touch.',
      'desc_julia': 'Interactive mathematical exploration of the morphing Julia Set fractal in real time with touch drag.',
      'desc_sakura': 'Procedurally generated cherry blossom trees with physics-based falling petals swayed by gyroscopic wind.',
      'desc_pachinko': '2D physics-based falling and collision of neon marbles over fixed circular pins with micro-haptic ticks.',
      'desc_kaleidoscope': 'Reflected geometric shapes in virtual symmetric radial sections that rotate with the gyroscope.',
    }
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? _localizedValues['es']?[key] ?? key;
  }

  // Getters for keys
  String get appTitle => get('app_title');
  String get tabAdjust => get('tab_adjust');
  String get tabLibrary => get('tab_library');
  String get tabOptions => get('tab_options');
  String get titleAdjust => get('title_adjust');
  String get titleLibrary => get('title_library');
  String get titleOptions => get('title_options');
  
  String activeWallpaper(String name) => get('active_wallpaper').replaceAll('{}', name);
  
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
  
  String formatSeconds(int val) => get('seconds').replaceAll('{}', val.toString());
  String get formatMinute => get('minute');
  String formatMinutes(int val) => get('minutes').replaceAll('{}', val.toString());
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
  String get engineVoronoi => get('engine_voronoi');
  String get engineWaveforms => get('engine_waveforms');
  String get engineBoids => get('engine_boids');
  String get engineJulia => get('engine_julia');
  String get engineSakura => get('engine_sakura');
  String get enginePachinko => get('engine_pachinko');
  String get engineKaleidoscope => get('engine_kaleidoscope');
  
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
  String get descVoronoi => get('desc_voronoi');
  String get descWaveforms => get('desc_waveforms');
  String get descBoids => get('desc_boids');
  String get descJulia => get('desc_julia');
  String get descSakura => get('desc_sakura');
  String get descPachinko => get('desc_pachinko');
  String get descKaleidoscope => get('desc_kaleidoscope');

  String skippedFiles(int count) => get('skipped_files').replaceAll('{}', count.toString());
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
