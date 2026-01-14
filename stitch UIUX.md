<!-- PANDU Navigation Map -->
<!DOCTYPE html>

<html class="dark" lang="en"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>PANDU Navigation Map</title>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<script id="tailwind-config">
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    colors: {
                        "primary": "#0df259",
                        "danger": "#ff3b30",
                        "background-light": "#f5f8f6",
                        "background-dark": "#050505",
                        "surface-dark": "#121212",
                    },
                    fontFamily: {
                        "display": ["Space Grotesk", "sans-serif"]
                    },
                    borderRadius: {"DEFAULT": "0.25rem", "lg": "0.5rem", "xl": "0.75rem", "2xl": "1rem", "full": "9999px"},
                    animation: {
                        'pulse-slow': 'pulse 3s cubic-bezier(0.4, 0, 0.6, 1) infinite',
                    }
                },
            },
        }
    </script>
<style>@import url("https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300;400;500;600;700&display=swap");
.map-texture {
    background-image: radial-gradient(circle at 50% 50%, rgba(13, 242, 89, 0.05) 0%, transparent 50%), repeating-linear-gradient(0deg, transparent, transparent 49px, rgba(255, 255, 255, 0.03) 50px), repeating-linear-gradient(90deg, transparent, transparent 49px, rgba(255, 255, 255, 0.03) 50px);
    background-size: 100% 100%, 100px 100px, 100px 100px
    }
.contour-lines {
    background-image: url(https://lh3.googleusercontent.com/aida-public/AB6AXuBErJm65Fwc_dGTQ4E6Fu2YfCpI4zjj_TxmZStQE-2Ll1REFvGr1Ae5-_MwcREp68LWzOpO_LZP2lmsO0HiiUMeZxIwWAee0AGOpOh-AOxr8uqay4is5oMe27Ab1802NwGZ9PBDJOmT2upM2CbddxSIuR1kLTxjD0wCMewgWodbJtxFJhOjpo7o6xwFCZw-tp01rdP5f0VxNwpeWZHLfE8_1HxYxfJTkUNaE2Xa4F9LT96eEzNx_1ZggLiOzfzP1FlNieW10juhWbhM);
    background-size: 200px 200px
    }
.glass-panel {
    background: rgba(20, 20, 20, 0.6);
    backdrop-filter: blur(12px);
    -webkit-backdrop-filter: blur(12px);
    border: 1px solid rgba(255, 255, 255, 0.1)
    }
.danger-glow {
    box-shadow: inset 0 0 50px 20px rgba(255, 59, 48, 0.15);
    animation: breathe 2s infinite alternate
    }
@keyframes breathe {
    from {
        box-shadow: inset 0 0 40px 10px rgba(255, 59, 48, 0.1);
        } to {
        box-shadow: inset 0 0 80px 30px rgba(255, 59, 48, 0.25);
        }
    }</style>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
  </head>
<body class="font-display bg-background-light dark:bg-background-dark text-white h-screen w-full overflow-hidden select-none">
<!-- Main Container -->
<div class="relative h-full w-full flex flex-col group/design-root danger-glow">
<!-- Top Status Bar Area (simulated) -->
<div class="absolute top-0 w-full h-12 z-50 flex justify-between items-center px-6 pt-2 pointer-events-none">
<span class="text-xs font-medium text-white/70">09:41</span>
<div class="flex gap-1">
<span class="material-symbols-outlined text-[18px] text-white/70">signal_cellular_alt</span>
<span class="material-symbols-outlined text-[18px] text-white/70">wifi</span>
<span class="material-symbols-outlined text-[18px] text-white/70">battery_5_bar</span>
</div>
</div>
<!-- 3D Map Background Layer -->
<div class="absolute inset-0 z-0 bg-background-dark overflow-hidden">
<!-- Simulated Satellite/Terrain Map -->
<div class="absolute inset-0 bg-cover bg-center opacity-40 mix-blend-overlay" data-alt="Dark abstract topographic map texture with contour lines" data-location="Swiss Alps" style="background-image: url('https://lh3.googleusercontent.com/aida-public/AB6AXuB5_fngukaYSei2RKSleWGAd47GTa5s3B4Bqj7Rwbicd31-bRrOD8QCSMO3nLq7hGs1G6iOL8fwVFoZYdHEEDwg9npzHfIclR88JRbeR9dgIBnD_zGpOm9UBDeHbWnHN6Tekg0XmV_8s1uOdjkJrrKHOOejxGdDdXBnnLZf7SnlQwWM3Fpw9e3ig8KOfiBzON6C7vTmgSVVMwJZLHDW-lg0n7nhG1NBSP2XaJB5IPzI9ssoj5bnJ4ZCTX3xH1YEW5zwqwwJT-m8xz0s');">
</div>
<!-- Custom CSS patterns for tactical feel -->
<div class="absolute inset-0 map-texture opacity-80"></div>
<div class="absolute inset-0 contour-lines opacity-30 rotate-12 scale-150"></div>
<!-- Trail Line -->
<svg class="absolute inset-0 w-full h-full pointer-events-none" style="filter: drop-shadow(0 0 8px rgba(13, 242, 89, 0.6));">
<path d="M -50 100 Q 100 400 200 300 T 500 800" fill="none" opacity="0.4" stroke="#0df259" stroke-dasharray="8 4" stroke-width="4"></path>
<path d="M 200 300 L 180 500 L 220 550" fill="none" stroke="#ff3b30" stroke-dasharray="4 2" stroke-width="4"></path>
</svg>
<!-- User Location Marker (Pulse) -->
<div class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-32 h-32 flex items-center justify-center pointer-events-none">
<div class="absolute w-full h-full bg-primary/20 rounded-full animate-ping opacity-20"></div>
<div class="absolute w-16 h-16 bg-primary/10 rounded-full animate-pulse"></div>
<div class="relative z-10 w-0 h-0 border-l-[10px] border-l-transparent border-r-[10px] border-r-transparent border-b-[20px] border-b-primary filter drop-shadow-[0_0_10px_rgba(13,242,89,0.8)]"></div>
<!-- Field of View Cone -->
<div class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-full w-[120px] h-[180px] bg-gradient-to-t from-primary/20 to-transparent -mt-2 clip-path-polygon transform -rotate-45 origin-bottom" style="clip-path: polygon(50% 100%, 0 0, 100% 0);"></div>
</div>
</div>
<!-- Floating HUD Telemetry -->
<div class="relative z-10 pt-16 px-4 flex justify-between items-start gap-2">
<!-- Altitude -->
<div class="glass-panel rounded-full h-10 px-4 flex items-center gap-2 shadow-lg">
<span class="material-symbols-outlined text-primary text-[20px]">landscape</span>
<div class="flex flex-col leading-none">
<span class="text-[10px] text-gray-400 font-bold tracking-wider uppercase">Alt</span>
<span class="text-sm font-bold text-white font-mono">2,450<span class="text-xs font-normal text-gray-400 ml-0.5">m</span></span>
</div>
</div>
<!-- Compass Bearing -->
<div class="glass-panel rounded-full h-10 px-4 flex items-center gap-2 shadow-lg min-w-[110px] justify-center">
<span class="material-symbols-outlined text-primary text-[20px]">explore</span>
<span class="text-sm font-bold text-white font-mono tracking-wide">285° NW</span>
</div>
<!-- Accuracy -->
<div class="glass-panel rounded-full h-10 px-4 flex items-center gap-2 shadow-lg">
<span class="material-symbols-outlined text-primary text-[20px]">my_location</span>
<div class="flex flex-col leading-none">
<span class="text-[10px] text-gray-400 font-bold tracking-wider uppercase">GPS</span>
<span class="text-sm font-bold text-white font-mono">±3<span class="text-xs font-normal text-gray-400 ml-0.5">m</span></span>
</div>
</div>
</div>
<!-- Map Controls (Side) -->
<div class="absolute right-4 top-1/2 -translate-y-1/2 z-10 flex flex-col gap-3">
<button class="glass-panel w-12 h-12 rounded-xl flex items-center justify-center text-white active:bg-white/10 transition-colors shadow-lg">
<span class="material-symbols-outlined">add</span>
</button>
<button class="glass-panel w-12 h-12 rounded-xl flex items-center justify-center text-white active:bg-white/10 transition-colors shadow-lg">
<span class="material-symbols-outlined">remove</span>
</button>
<button class="glass-panel w-12 h-12 rounded-xl flex items-center justify-center text-primary active:bg-white/10 transition-colors shadow-lg mt-4 border-primary/30">
<span class="material-symbols-outlined">near_me</span>
</button>
<button class="glass-panel w-12 h-12 rounded-xl flex items-center justify-center text-white active:bg-white/10 transition-colors shadow-lg">
<span class="material-symbols-outlined">layers</span>
</button>
</div>
<!-- Off-Trail Warning Badge -->
<div class="absolute top-32 w-full flex justify-center z-10 pointer-events-none">
<div class="bg-danger/90 backdrop-blur-md px-4 py-1.5 rounded-full border border-red-500/50 shadow-[0_0_20px_rgba(255,59,48,0.4)] flex items-center gap-2 animate-pulse">
<span class="material-symbols-outlined text-white text-[18px]">warning</span>
<span class="text-xs font-bold tracking-widest text-white uppercase">Off Trail Detected</span>
</div>
</div>
<!-- Bottom Sheet / Drawer -->
<div class="absolute bottom-0 w-full z-20">
<div class="mx-2 mb-2 bg-surface-dark/95 backdrop-blur-xl rounded-t-[2rem] rounded-b-[2rem] border border-white/5 shadow-2xl overflow-hidden">
<!-- Drag Handle -->
<div class="w-full flex justify-center pt-3 pb-1">
<div class="w-12 h-1 rounded-full bg-white/20"></div>
</div>
<!-- Content -->
<div class="px-5 pb-6 pt-2">
<!-- Warning Header -->
<div class="flex items-center gap-4 mb-6">
<div class="w-12 h-12 rounded-full bg-danger/20 flex items-center justify-center shrink-0 border border-danger/30">
<span class="material-symbols-outlined text-danger text-[24px]">wrong_location</span>
</div>
<div class="flex-1">
<h2 class="text-white text-lg font-bold leading-tight">Deviated from Course</h2>
<p class="text-gray-400 text-sm mt-0.5">You are 150m East of the planned route.</p>
</div>
</div>
<!-- Stats Row -->
<div class="grid grid-cols-3 gap-3 mb-6">
<div class="bg-white/5 rounded-xl p-3 flex flex-col items-center justify-center border border-white/5">
<span class="text-[10px] uppercase tracking-wider text-gray-500 mb-1">Return Time</span>
<span class="text-lg font-bold font-mono">15<span class="text-xs text-gray-400 ml-0.5">m</span></span>
</div>
<div class="bg-white/5 rounded-xl p-3 flex flex-col items-center justify-center border border-white/5">
<span class="text-[10px] uppercase tracking-wider text-gray-500 mb-1">Sunset</span>
<span class="text-lg font-bold font-mono">18:42</span>
</div>
<div class="bg-white/5 rounded-xl p-3 flex flex-col items-center justify-center border border-white/5">
<span class="text-[10px] uppercase tracking-wider text-gray-500 mb-1">Battery</span>
<span class="text-lg font-bold font-mono text-primary">82<span class="text-xs text-gray-400 ml-0.5">%</span></span>
</div>
</div>
<!-- Action Button -->
<button class="w-full bg-danger hover:bg-red-600 text-white font-bold h-14 rounded-xl flex items-center justify-center gap-3 shadow-[0_4px_20px_rgba(255,59,48,0.3)] transition-all active:scale-[0.98]">
<span class="material-symbols-outlined text-[24px]">u_turn_left</span>
<span class="tracking-wider">INITIATE BACKTRACK</span>
</button>
</div>
</div>
<!-- Safe Area Spacer for iOS Home Indicator -->
<div class="h-6 w-full"></div>
</div>
</div>
</body></html>

<!-- PANDU Navigation Map -->
<!DOCTYPE html>
<html class="dark" lang="en"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>PANDU Navigation Map</title>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<script id="tailwind-config">
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    colors: {
                        "primary": "#0df259",
                        "danger": "#ff3b30",
                        "background-light": "#f5f8f6",
                        "background-dark": "#050505",
                        "surface-dark": "#121212",
                    },
                    fontFamily: {
                        "display": ["Space Grotesk", "sans-serif"]
                    },
                    borderRadius: {"DEFAULT": "0.25rem", "lg": "0.5rem", "xl": "0.75rem", "2xl": "1rem", "full": "9999px"},
                    animation: {
                        'pulse-slow': 'pulse 3s cubic-bezier(0.4, 0, 0.6, 1) infinite',
                    }
                },
            },
        }
    </script>
<style>@import url("https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300;400;500;600;700&display=swap");
.map-texture {
    background-image: radial-gradient(circle at 50% 50%, rgba(13, 242, 89, 0.05) 0%, transparent 50%), repeating-linear-gradient(0deg, transparent, transparent 49px, rgba(255, 255, 255, 0.03) 50px), repeating-linear-gradient(90deg, transparent, transparent 49px, rgba(255, 255, 255, 0.03) 50px);
    background-size: 100% 100%, 100px 100px, 100px 100px
    }
.contour-lines {
    background-image: url(https://lh3.googleusercontent.com/aida-public/AB6AXuBErJm65Fwc_dGTQ4E6Fu2YfCpI4zjj_TxmZStQE-2Ll1REFvGr1Ae5-_MwcREp68LWzOpO_LZP2lmsO0HiiUMeZxIwWAee0AGOpOh-AOxr8uqay4is5oMe27Ab1802NwGZ9PBDJOmT2upM2CbddxSIuR1kLTxjD0wCMewgWodbJtxFJhOjpo7o6xwFCZw-tp01rdP5f0VxNwpeWZHLfE8_1HxYxfJTkUNaE2Xa4F9LT96eEzNx_1ZggLiOzfzP1FlNieW10juhWbhM);
    background-size: 200px 200px
    }
.glass-panel {
    background: rgba(20, 20, 20, 0.6);
    backdrop-filter: blur(12px);
    -webkit-backdrop-filter: blur(12px);
    border: 1px solid rgba(255, 255, 255, 0.1)
    }
.danger-glow {
    box-shadow: inset 0 0 50px 20px rgba(255, 59, 48, 0.15);
    animation: breathe 2s infinite alternate
    }
@keyframes breathe {
    from {
        box-shadow: inset 0 0 40px 10px rgba(255, 59, 48, 0.1);
        } to {
        box-shadow: inset 0 0 80px 30px rgba(255, 59, 48, 0.25);
        }
    }</style>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
  </head>
<body class="font-display bg-background-light dark:bg-background-dark text-white h-screen w-full overflow-hidden select-none">
<div class="relative h-full w-full flex flex-col group/design-root danger-glow">
<div class="absolute top-0 w-full h-12 z-50 flex justify-between items-center px-6 pt-2 pointer-events-none">
<span class="text-xs font-medium text-white/70">09:41</span>
<div class="flex gap-1">
<span class="material-symbols-outlined text-[18px] text-white/70">signal_cellular_alt</span>
<span class="material-symbols-outlined text-[18px] text-white/70">wifi</span>
<span class="material-symbols-outlined text-[18px] text-white/70">battery_5_bar</span>
</div>
</div>
<div class="absolute inset-0 z-0 bg-background-dark overflow-hidden">
<div class="absolute inset-0 bg-cover bg-center opacity-40 mix-blend-overlay" data-alt="Dark abstract topographic map texture with contour lines" data-location="Swiss Alps" style="background-image: url('https://lh3.googleusercontent.com/aida-public/AB6AXuB5_fngukaYSei2RKSleWGAd47GTa5s3B4Bqj7Rwbicd31-bRrOD8QCSMO3nLq7hGs1G6iOL8fwVFoZYdHEEDwg9npzHfIclR88JRbeR9dgIBnD_zGpOm9UBDeHbWnHN6Tekg0XmV_8s1uOdjkJrrKHOOejxGdDdXBnnLZf7SnlQwWM3Fpw9e3ig8KOfiBzON6C7vTmgSVVMwJZLHDW-lg0n7nhG1NBSP2XaJB5IPzI9ssoj5bnJ4ZCTX3xH1YEW5zwqwwJT-m8xz0s');">
</div>
<div class="absolute inset-0 map-texture opacity-80"></div>
<div class="absolute inset-0 contour-lines opacity-30 rotate-12 scale-150"></div>
<svg class="absolute inset-0 w-full h-full pointer-events-none" style="filter: drop-shadow(0 0 8px rgba(13, 242, 89, 0.6));">
<path d="M -50 100 Q 100 400 200 300 T 500 800" fill="none" opacity="0.4" stroke="#0df259" stroke-dasharray="8 4" stroke-width="4"></path>
<path d="M 200 300 L 180 500 L 220 550" fill="none" stroke="#ff3b30" stroke-dasharray="4 2" stroke-width="4"></path>
</svg>
<div class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-32 h-32 flex items-center justify-center pointer-events-none">
<div class="absolute w-full h-full bg-primary/20 rounded-full animate-ping opacity-20"></div>
<div class="absolute w-16 h-16 bg-primary/10 rounded-full animate-pulse"></div>
<div class="relative z-10 w-0 h-0 border-l-[10px] border-l-transparent border-r-[10px] border-r-transparent border-b-[20px] border-b-primary filter drop-shadow-[0_0_10px_rgba(13,242,89,0.8)]"></div>
<div class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-full w-[120px] h-[180px] bg-gradient-to-t from-primary/20 to-transparent -mt-2 clip-path-polygon transform -rotate-45 origin-bottom" style="clip-path: polygon(50% 100%, 0 0, 100% 0);"></div>
</div>
</div>
<div class="relative z-10 pt-16 px-4 flex justify-between items-start gap-2">
<div class="glass-panel rounded-full h-10 px-4 flex items-center gap-2 shadow-lg">
<span class="material-symbols-outlined text-primary text-[20px]">landscape</span>
<div class="flex flex-col leading-none">
<span class="text-[10px] text-gray-400 font-bold tracking-wider uppercase">Alt</span>
<span class="text-sm font-bold text-white font-mono">2,450<span class="text-xs font-normal text-gray-400 ml-0.5">m</span></span>
</div>
</div>
<div class="glass-panel rounded-full h-10 px-4 flex items-center gap-2 shadow-lg min-w-[110px] justify-center">
<span class="material-symbols-outlined text-primary text-[20px]">explore</span>
<span class="text-sm font-bold text-white font-mono tracking-wide">285° NW</span>
</div>
<div class="glass-panel rounded-full h-10 px-4 flex items-center gap-2 shadow-lg">
<span class="material-symbols-outlined text-primary text-[20px]">my_location</span>
<div class="flex flex-col leading-none">
<span class="text-[10px] text-gray-400 font-bold tracking-wider uppercase">GPS</span>
<span class="text-sm font-bold text-white font-mono">±3<span class="text-xs font-normal text-gray-400 ml-0.5">m</span></span>
</div>
</div>
</div>
<div class="absolute right-4 top-1/2 -translate-y-1/2 z-10 flex flex-col gap-3">
<button class="glass-panel w-12 h-12 rounded-xl flex items-center justify-center text-white active:bg-white/10 transition-colors shadow-lg">
<span class="material-symbols-outlined">add</span>
</button>
<button class="glass-panel w-12 h-12 rounded-xl flex items-center justify-center text-white active:bg-white/10 transition-colors shadow-lg">
<span class="material-symbols-outlined">remove</span>
</button>
<button class="glass-panel w-12 h-12 rounded-xl flex items-center justify-center text-primary active:bg-white/10 transition-colors shadow-lg mt-4 border-primary/30">
<span class="material-symbols-outlined">near_me</span>
</button>
<button class="glass-panel w-12 h-12 rounded-xl flex items-center justify-center text-white active:bg-white/10 transition-colors shadow-lg">
<span class="material-symbols-outlined">layers</span>
</button>
</div>
<div class="absolute top-32 w-full flex justify-center z-10 pointer-events-none">
<div class="bg-danger/90 backdrop-blur-md px-4 py-1.5 rounded-full border border-red-500/50 shadow-[0_0_20px_rgba(255,59,48,0.4)] flex items-center gap-2 animate-pulse">
<span class="material-symbols-outlined text-white text-[18px]">warning</span>
<span class="text-xs font-bold tracking-widest text-white uppercase">Off Trail Detected</span>
</div>
</div>
<div class="absolute -bottom-[250px] w-full z-20 transition-all duration-300 ease-in-out hover:bottom-0">
<div class="mx-2 mb-2 bg-surface-dark/95 backdrop-blur-xl rounded-t-[2rem] rounded-b-[2rem] border border-white/5 shadow-2xl overflow-hidden">
<div class="w-full flex justify-center pt-3 pb-1">
<div class="w-12 h-1 rounded-full bg-white/20"></div>
</div>
<div class="px-5 pb-6 pt-2">
<div class="flex items-center gap-4 mb-6">
<div class="w-12 h-12 rounded-full bg-danger/20 flex items-center justify-center shrink-0 border border-danger/30">
<span class="material-symbols-outlined text-danger text-[24px]">wrong_location</span>
</div>
<div class="flex-1">
<h2 class="text-white text-lg font-bold leading-tight">Deviated from Course</h2>
<p class="text-gray-400 text-sm mt-0.5">You are 150m East of the planned route.</p>
</div>
</div>
<div class="grid grid-cols-3 gap-3 mb-6">
<div class="bg-white/5 rounded-xl p-3 flex flex-col items-center justify-center border border-white/5">
<span class="text-[10px] uppercase tracking-wider text-gray-500 mb-1">Return Time</span>
<span class="text-lg font-bold font-mono">15<span class="text-xs text-gray-400 ml-0.5">m</span></span>
</div>
<div class="bg-white/5 rounded-xl p-3 flex flex-col items-center justify-center border border-white/5">
<span class="text-[10px] uppercase tracking-wider text-gray-500 mb-1">Sunset</span>
<span class="text-lg font-bold font-mono">18:42</span>
</div>
<div class="bg-white/5 rounded-xl p-3 flex flex-col items-center justify-center border border-white/5">
<span class="text-[10px] uppercase tracking-wider text-gray-500 mb-1">Battery</span>
<span class="text-lg font-bold font-mono text-primary">82<span class="text-xs text-gray-400 ml-0.5">%</span></span>
</div>
</div>
<button class="w-full bg-danger hover:bg-red-600 text-white font-bold h-14 rounded-xl flex items-center justify-center gap-3 shadow-[0_4px_20px_rgba(255,59,48,0.3)] transition-all active:scale-[0.98]">
<span class="material-symbols-outlined text-[24px]">u_turn_left</span>
<span class="tracking-wider">INITIATE BACKTRACK</span>
</button>
</div>
</div>
<div class="h-6 w-full"></div>
</div>
</div>
</body></html>

<!-- PANDU Navigation Map -->
<!DOCTYPE html>
<html class="dark" lang="en"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>PANDU Survival Tips Widget</title>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<script id="tailwind-config">
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    colors: {
                        "primary": "#0df259",
                        "danger": "#ff3b30",
                        "background-light": "#f5f8f6",
                        "background-dark": "#050505",
                        "surface-dark": "#121212",
                    },
                    fontFamily: {
                        "display": ["Space Grotesk", "sans-serif"]
                    },
                    borderRadius: {"DEFAULT": "0.25rem", "lg": "0.5rem", "xl": "0.75rem", "2xl": "1rem", "full": "9999px"},
                    animation: {
                        'pulse-slow': 'pulse 3s cubic-bezier(0.4, 0, 0.6, 1) infinite',
                    }
                },
            },
        }
    </script>
<style>@import url("https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300;400;500;600;700&display=swap");
.map-texture {
    background-image: radial-gradient(circle at 50% 50%, rgba(13, 242, 89, 0.05) 0%, transparent 50%), repeating-linear-gradient(0deg, transparent, transparent 49px, rgba(255, 255, 255, 0.03) 50px), repeating-linear-gradient(90deg, transparent, transparent 49px, rgba(255, 255, 255, 0.03) 50px);
    background-size: 100% 100%, 100px 100px, 100px 100px
    }
.contour-lines {
    background-image: url(https://lh3.googleusercontent.com/aida-public/AB6AXuBErJm65Fwc_dGTQ4E6Fu2YfCpI4zjj_TxmZStQE-2Ll1REFvGr1Ae5-_MwcREp68LWzOpO_LZP2lmsO0HiiUMeZxIwWAee0AGOpOh-AOxr8uqay4is5oMe27Ab1802NwGZ9PBDJOmT2upM2CbddxSIuR1kLTxjD0wCMewgWodbJtxFJhOjpo7o6xwFCZw-tp01rdP5f0VxNwpeWZHLfE8_1HxYxfJTkUNaE2Xa4F9LT96eEzNx_1ZggLiOzfzP1FlNieW10juhWbhM);
    background-size: 200px 200px
    }
.glass-panel {
    background: rgba(20, 20, 20, 0.6);
    backdrop-filter: blur(12px);
    -webkit-backdrop-filter: blur(12px);
    border: 1px solid rgba(255, 255, 255, 0.1)
    }
.danger-glow {
    box-shadow: inset 0 0 50px 20px rgba(255, 59, 48, 0.15);
    animation: breathe 2s infinite alternate
    }
@keyframes breathe {
    from {
        box-shadow: inset 0 0 40px 10px rgba(255, 59, 48, 0.1);
        } to {
        box-shadow: inset 0 0 80px 30px rgba(255, 59, 48, 0.25);
        }
    }</style>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
  </head>
<body class="font-display bg-background-light dark:bg-background-dark text-white h-screen w-full overflow-hidden select-none">
<div class="relative h-full w-full flex flex-col group/design-root danger-glow">
<div class="absolute top-0 w-full h-12 z-50 flex justify-between items-center px-6 pt-2 pointer-events-none">
<span class="text-xs font-medium text-white/70">09:41</span>
<div class="flex gap-1">
<span class="material-symbols-outlined text-[18px] text-white/70">signal_cellular_alt</span>
<span class="material-symbols-outlined text-[18px] text-white/70">wifi</span>
<span class="material-symbols-outlined text-[18px] text-white/70">battery_5_bar</span>
</div>
</div>
<div class="absolute inset-0 z-0 bg-background-dark overflow-hidden">
<div class="absolute inset-0 bg-cover bg-center opacity-40 mix-blend-overlay" data-alt="Dark abstract topographic map texture with contour lines" data-location="Swiss Alps" style="background-image: url('https://lh3.googleusercontent.com/aida-public/AB6AXuB5_fngukaYSei2RKSleWGAd47GTa5s3B4Bqj7Rwbicd31-bRrOD8QCSMO3nLq7hGs1G6iOL8fwVFoZYdHEEDwg9npzHfIclR88JRbeR9dgIBnD_zGpOm9UBDeHbWnHN6Tekg0XmV_8s1uOdjkJrrKHOOejxGdDdXBnnLZf7SnlQwWM3Fpw9e3ig8KOfiBzON6C7vTmgSVVMwJZLHDW-lg0n7nhG1NBSP2XaJB5IPzI9ssoj5bnJ4ZCTX3xH1YEW5zwqwwJT-m8xz0s');">
</div>
<div class="absolute inset-0 map-texture opacity-80"></div>
<div class="absolute inset-0 contour-lines opacity-30 rotate-12 scale-150"></div>
<svg class="absolute inset-0 w-full h-full pointer-events-none" style="filter: drop-shadow(0 0 8px rgba(13, 242, 89, 0.6));">
<path d="M -50 100 Q 100 400 200 300 T 500 800" fill="none" opacity="0.4" stroke="#0df259" stroke-dasharray="8 4" stroke-width="4"></path>
<path d="M 200 300 L 180 500 L 220 550" fill="none" stroke="#ff3b30" stroke-dasharray="4 2" stroke-width="4"></path>
</svg>
<div class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-32 h-32 flex items-center justify-center pointer-events-none">
<div class="absolute w-full h-full bg-primary/20 rounded-full animate-ping opacity-20"></div>
<div class="absolute w-16 h-16 bg-primary/10 rounded-full animate-pulse"></div>
<div class="relative z-10 w-0 h-0 border-l-[10px] border-l-transparent border-r-[10px] border-r-transparent border-b-[20px] border-b-primary filter drop-shadow-[0_0_10px_rgba(13,242,89,0.8)]"></div>
<div class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-full w-[120px] h-[180px] bg-gradient-to-t from-primary/20 to-transparent -mt-2 clip-path-polygon transform -rotate-45 origin-bottom" style="clip-path: polygon(50% 100%, 0 0, 100% 0);"></div>
</div>
</div>
<div class="relative z-10 pt-16 px-4 flex justify-between items-start gap-2">
<div class="glass-panel rounded-full h-10 px-4 flex items-center gap-2 shadow-lg">
<span class="material-symbols-outlined text-primary text-[20px]">landscape</span>
<div class="flex flex-col leading-none">
<span class="text-[10px] text-gray-400 font-bold tracking-wider uppercase">Alt</span>
<span class="text-sm font-bold text-white font-mono">2,450<span class="text-xs font-normal text-gray-400 ml-0.5">m</span></span>
</div>
</div>
<div class="glass-panel rounded-full h-10 px-4 flex items-center gap-2 shadow-lg min-w-[110px] justify-center">
<span class="material-symbols-outlined text-primary text-[20px]">explore</span>
<span class="text-sm font-bold text-white font-mono tracking-wide">285° NW</span>
</div>
<div class="glass-panel rounded-full h-10 px-4 flex items-center gap-2 shadow-lg">
<span class="material-symbols-outlined text-primary text-[20px]">my_location</span>
<div class="flex flex-col leading-none">
<span class="text-[10px] text-gray-400 font-bold tracking-wider uppercase">GPS</span>
<span class="text-sm font-bold text-white font-mono">±3<span class="text-xs font-normal text-gray-400 ml-0.5">m</span></span>
</div>
</div>
</div>
<div class="absolute right-4 top-1/2 -translate-y-1/2 z-10 flex flex-col gap-3">
<button class="glass-panel w-12 h-12 rounded-xl flex items-center justify-center text-white active:bg-white/10 transition-colors shadow-lg">
<span class="material-symbols-outlined">add</span>
</button>
<button class="glass-panel w-12 h-12 rounded-xl flex items-center justify-center text-white active:bg-white/10 transition-colors shadow-lg">
<span class="material-symbols-outlined">remove</span>
</button>
<button class="glass-panel w-12 h-12 rounded-xl flex items-center justify-center text-primary active:bg-white/10 transition-colors shadow-lg mt-4 border-primary/30">
<span class="material-symbols-outlined">near_me</span>
</button>
<button class="glass-panel w-12 h-12 rounded-xl flex items-center justify-center text-white active:bg-white/10 transition-colors shadow-lg">
<span class="material-symbols-outlined">layers</span>
</button>
</div>
<div class="absolute top-32 w-full flex justify-center z-10 pointer-events-none">
<div class="bg-danger/90 backdrop-blur-md px-4 py-1.5 rounded-full border border-red-500/50 shadow-[0_0_20px_rgba(255,59,48,0.4)] flex items-center gap-2 animate-pulse">
<span class="material-symbols-outlined text-white text-[18px]">warning</span>
<span class="text-xs font-bold tracking-widest text-white uppercase">Off Trail Detected</span>
</div>
</div>
<div class="absolute bottom-0 w-full z-20">
<div class="mx-2 mb-2 bg-surface-dark/95 backdrop-blur-xl rounded-t-[2rem] rounded-b-[2rem] border border-white/5 shadow-2xl overflow-hidden">
<div class="w-full flex justify-center pt-3 pb-1">
<div class="w-12 h-1 rounded-full bg-white/20"></div>
</div>
<div class="px-5 pb-6 pt-2">
<div class="flex items-center gap-4 mb-5">
<div class="w-12 h-12 rounded-full bg-danger/20 flex items-center justify-center shrink-0 border border-danger/30">
<span class="material-symbols-outlined text-danger text-[24px]">wrong_location</span>
</div>
<div class="flex-1">
<h2 class="text-white text-lg font-bold leading-tight">Deviated from Course</h2>
<p class="text-gray-400 text-sm mt-0.5">You are 150m East of the planned route.</p>
</div>
</div>
<div class="grid grid-cols-3 gap-3 mb-5">
<div class="bg-white/5 rounded-xl p-3 flex flex-col items-center justify-center border border-white/5">
<span class="text-[10px] uppercase tracking-wider text-gray-500 mb-1">Return Time</span>
<span class="text-lg font-bold font-mono">15<span class="text-xs text-gray-400 ml-0.5">m</span></span>
</div>
<div class="bg-white/5 rounded-xl p-3 flex flex-col items-center justify-center border border-white/5">
<span class="text-[10px] uppercase tracking-wider text-gray-500 mb-1">Sunset</span>
<span class="text-lg font-bold font-mono">18:42</span>
</div>
<div class="bg-white/5 rounded-xl p-3 flex flex-col items-center justify-center border border-white/5">
<span class="text-[10px] uppercase tracking-wider text-gray-500 mb-1">Battery</span>
<span class="text-lg font-bold font-mono text-primary">82<span class="text-xs text-gray-400 ml-0.5">%</span></span>
</div>
</div>
<div class="mb-5">
<div class="flex items-center justify-between mb-3 px-1">
<h3 class="text-xs font-bold text-gray-400 uppercase tracking-widest">Survival Guide</h3>
<span class="text-[10px] text-primary/80 bg-primary/10 px-2 py-0.5 rounded border border-primary/20">RECOMMENDED</span>
</div>
<div class="grid grid-cols-3 gap-3">
<div class="bg-white/5 hover:bg-white/10 border border-white/10 rounded-xl p-3 flex flex-col items-center justify-center gap-2 transition-all">
<div class="w-10 h-10 rounded-full bg-blue-500/10 border border-blue-500/20 flex items-center justify-center shadow-[0_0_15px_rgba(59,130,246,0.1)]">
<span class="material-symbols-outlined text-blue-400 text-[20px]">water_drop</span>
</div>
<span class="text-[11px] font-medium text-gray-300">Find Water</span>
</div>
<div class="bg-white/5 hover:bg-white/10 border border-white/10 rounded-xl p-3 flex flex-col items-center justify-center gap-2 transition-all">
<div class="w-10 h-10 rounded-full bg-amber-500/10 border border-amber-500/20 flex items-center justify-center shadow-[0_0_15px_rgba(245,158,11,0.1)]">
<span class="material-symbols-outlined text-amber-400 text-[20px]">roofing</span>
</div>
<span class="text-[11px] font-medium text-gray-300">Build Shelter</span>
</div>
<div class="bg-white/5 hover:bg-white/10 border border-white/10 rounded-xl p-3 flex flex-col items-center justify-center gap-2 transition-all">
<div class="w-10 h-10 rounded-full bg-red-500/10 border border-red-500/20 flex items-center justify-center shadow-[0_0_15px_rgba(239,68,68,0.1)]">
<span class="material-symbols-outlined text-red-400 text-[20px]">local_fire_department</span>
</div>
<span class="text-[11px] font-medium text-gray-300">Start Fire</span>
</div>
</div>
<div class="mt-3 flex gap-3">
<div class="flex-1 bg-white/5 border border-white/10 rounded-xl p-3 flex items-center justify-between">
<div class="flex items-center gap-2">
<span class="material-symbols-outlined text-white/60 text-[18px]">emergency</span>
<span class="text-xs text-gray-300">Emergency Beacon</span>
</div>
<div class="w-2 h-2 rounded-full bg-primary animate-pulse shadow-[0_0_8px_rgba(13,242,89,0.8)]"></div>
</div>
</div>
</div>
<button class="w-full bg-danger hover:bg-red-600 text-white font-bold h-14 rounded-xl flex items-center justify-center gap-3 shadow-[0_4px_20px_rgba(255,59,48,0.3)] transition-all active:scale-[0.98]">
<span class="material-symbols-outlined text-[24px]">u_turn_left</span>
<span class="tracking-wider">INITIATE BACKTRACK</span>
</button>
</div>
</div>
<div class="h-6 w-full"></div>
</div>
</div>
</body></html>

<!-- PANDU Navigation Map -->
<!DOCTYPE html>
<html class="dark" lang="en"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>PANDU Tactical Compass Widget</title>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<script id="tailwind-config">
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    colors: {
                        "primary": "#0df259",
                        "danger": "#ff3b30",
                        "background-light": "#f5f8f6",
                        "background-dark": "#050505",
                        "surface-dark": "#121212",
                    },
                    fontFamily: {
                        "display": ["Space Grotesk", "sans-serif"]
                    },
                    borderRadius: {"DEFAULT": "0.25rem", "lg": "0.5rem", "xl": "0.75rem", "2xl": "1rem", "full": "9999px"},
                    animation: {
                        'pulse-slow': 'pulse 3s cubic-bezier(0.4, 0, 0.6, 1) infinite',
                    }
                },
            },
        }
    </script>
<style>@import url("https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300;400;500;600;700&display=swap");
.map-texture {
    background-image: radial-gradient(circle at 50% 50%, rgba(13, 242, 89, 0.05) 0%, transparent 50%), repeating-linear-gradient(0deg, transparent, transparent 49px, rgba(255, 255, 255, 0.03) 50px), repeating-linear-gradient(90deg, transparent, transparent 49px, rgba(255, 255, 255, 0.03) 50px);
    background-size: 100% 100%, 100px 100px, 100px 100px
    }
.contour-lines {
    background-image: url(https://lh3.googleusercontent.com/aida-public/AB6AXuBErJm65Fwc_dGTQ4E6Fu2YfCpI4zjj_TxmZStQE-2Ll1REFvGr1Ae5-_MwcREp68LWzOpO_LZP2lmsO0HiiUMeZxIwWAee0AGOpOh-AOxr8uqay4is5oMe27Ab1802NwGZ9PBDJOmT2upM2CbddxSIuR1kLTxjD0wCMewgWodbJtxFJhOjpo7o6xwFCZw-tp01rdP5f0VxNwpeWZHLfE8_1HxYxfJTkUNaE2Xa4F9LT96eEzNx_1ZggLiOzfzP1FlNieW10juhWbhM);
    background-size: 200px 200px
    }
.glass-panel {
    background: rgba(20, 20, 20, 0.6);
    backdrop-filter: blur(12px);
    -webkit-backdrop-filter: blur(12px);
    border: 1px solid rgba(255, 255, 255, 0.1)
    }
.danger-glow {
    box-shadow: inset 0 0 50px 20px rgba(255, 59, 48, 0.15);
    animation: breathe 2s infinite alternate
    }
@keyframes breathe {
    from {
        box-shadow: inset 0 0 40px 10px rgba(255, 59, 48, 0.1);
        } to {
        box-shadow: inset 0 0 80px 30px rgba(255, 59, 48, 0.25);
        }
    }</style>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
  </head>
<body class="font-display bg-background-light dark:bg-background-dark text-white h-screen w-full overflow-hidden select-none">
<div class="relative h-full w-full flex flex-col group/design-root danger-glow">
<div class="absolute top-0 w-full h-12 z-50 flex justify-between items-center px-6 pt-2 pointer-events-none">
<span class="text-xs font-medium text-white/70">09:41</span>
<div class="flex gap-1">
<span class="material-symbols-outlined text-[18px] text-white/70">signal_cellular_alt</span>
<span class="material-symbols-outlined text-[18px] text-white/70">wifi</span>
<span class="material-symbols-outlined text-[18px] text-white/70">battery_5_bar</span>
</div>
</div>
<div class="absolute inset-0 z-0 bg-background-dark overflow-hidden">
<div class="absolute inset-0 bg-cover bg-center opacity-40 mix-blend-overlay" data-alt="Dark abstract topographic map texture with contour lines" data-location="Swiss Alps" style="background-image: url('https://lh3.googleusercontent.com/aida-public/AB6AXuB5_fngukaYSei2RKSleWGAd47GTa5s3B4Bqj7Rwbicd31-bRrOD8QCSMO3nLq7hGs1G6iOL8fwVFoZYdHEEDwg9npzHfIclR88JRbeR9dgIBnD_zGpOm9UBDeHbWnHN6Tekg0XmV_8s1uOdjkJrrKHOOejxGdDdXBnnLZf7SnlQwWM3Fpw9e3ig8KOfiBzON6C7vTmgSVVMwJZLHDW-lg0n7nhG1NBSP2XaJB5IPzI9ssoj5bnJ4ZCTX3xH1YEW5zwqwwJT-m8xz0s');">
</div>
<div class="absolute inset-0 map-texture opacity-80"></div>
<div class="absolute inset-0 contour-lines opacity-30 rotate-12 scale-150"></div>
<svg class="absolute inset-0 w-full h-full pointer-events-none" style="filter: drop-shadow(0 0 8px rgba(13, 242, 89, 0.6));">
<path d="M -50 100 Q 100 400 200 300 T 500 800" fill="none" opacity="0.4" stroke="#0df259" stroke-dasharray="8 4" stroke-width="4"></path>
<path d="M 200 300 L 180 500 L 220 550" fill="none" stroke="#ff3b30" stroke-dasharray="4 2" stroke-width="4"></path>
</svg>
<div class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-32 h-32 flex items-center justify-center pointer-events-none">
<div class="absolute w-full h-full bg-primary/20 rounded-full animate-ping opacity-20"></div>
<div class="absolute w-16 h-16 bg-primary/10 rounded-full animate-pulse"></div>
<div class="relative z-10 w-0 h-0 border-l-[10px] border-l-transparent border-r-[10px] border-r-transparent border-b-[20px] border-b-primary filter drop-shadow-[0_0_10px_rgba(13,242,89,0.8)]"></div>
<div class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-full w-[120px] h-[180px] bg-gradient-to-t from-primary/20 to-transparent -mt-2 clip-path-polygon transform -rotate-45 origin-bottom" style="clip-path: polygon(50% 100%, 0 0, 100% 0);"></div>
</div>
</div>
<div class="relative z-10 pt-16 px-4 flex justify-between items-start gap-2">
<div class="glass-panel rounded-full h-10 px-4 flex items-center gap-2 shadow-lg">
<span class="material-symbols-outlined text-primary text-[20px]">landscape</span>
<div class="flex flex-col leading-none">
<span class="text-[10px] text-gray-400 font-bold tracking-wider uppercase">Alt</span>
<span class="text-sm font-bold text-white font-mono">2,450<span class="text-xs font-normal text-gray-400 ml-0.5">m</span></span>
</div>
</div>
<div class="glass-panel rounded-full h-10 px-4 flex items-center gap-2 shadow-lg min-w-[110px] justify-center">
<span class="material-symbols-outlined text-primary text-[20px]">explore</span>
<span class="text-sm font-bold text-white font-mono tracking-wide">285° NW</span>
</div>
<div class="glass-panel rounded-full h-10 px-4 flex items-center gap-2 shadow-lg">
<span class="material-symbols-outlined text-primary text-[20px]">my_location</span>
<div class="flex flex-col leading-none">
<span class="text-[10px] text-gray-400 font-bold tracking-wider uppercase">GPS</span>
<span class="text-sm font-bold text-white font-mono">±3<span class="text-xs font-normal text-gray-400 ml-0.5">m</span></span>
</div>
</div>
</div>
<div class="absolute right-4 top-1/2 -translate-y-1/2 z-10 flex flex-col gap-3">
<button class="glass-panel w-12 h-12 rounded-xl flex items-center justify-center text-white active:bg-white/10 transition-colors shadow-lg">
<span class="material-symbols-outlined">add</span>
</button>
<button class="glass-panel w-12 h-12 rounded-xl flex items-center justify-center text-white active:bg-white/10 transition-colors shadow-lg">
<span class="material-symbols-outlined">remove</span>
</button>
<button class="glass-panel w-12 h-12 rounded-xl flex items-center justify-center text-primary active:bg-white/10 transition-colors shadow-lg mt-4 border-primary/30">
<span class="material-symbols-outlined">near_me</span>
</button>
<button class="glass-panel w-12 h-12 rounded-xl flex items-center justify-center text-white active:bg-white/10 transition-colors shadow-lg">
<span class="material-symbols-outlined">layers</span>
</button>
</div>
<div class="absolute top-32 w-full flex justify-center z-10 pointer-events-none">
<div class="bg-danger/90 backdrop-blur-md px-4 py-1.5 rounded-full border border-red-500/50 shadow-[0_0_20px_rgba(255,59,48,0.4)] flex items-center gap-2 animate-pulse">
<span class="material-symbols-outlined text-white text-[18px]">warning</span>
<span class="text-xs font-bold tracking-widest text-white uppercase">Off Trail Detected</span>
</div>
</div>
<div class="absolute bottom-0 w-full z-20">
<div class="mx-2 mb-2 bg-surface-dark/90 backdrop-blur-xl rounded-[2.5rem] border border-white/10 shadow-2xl overflow-hidden ring-1 ring-white/5">
<div class="w-full flex justify-center pt-4 pb-2">
<div class="w-16 h-1 rounded-full bg-white/20"></div>
</div>
<div class="px-6 pb-8 flex flex-col items-center">
<div class="relative w-64 h-64 my-6 flex items-center justify-center">
<svg class="absolute inset-0 w-full h-full text-white/40" viewBox="0 0 100 100">
<circle cx="50" cy="50" fill="none" r="49" stroke="currentColor" stroke-dasharray="0.5 3" stroke-width="0.5"></circle>
<circle cx="50" cy="50" fill="none" r="38" stroke="currentColor" stroke-opacity="0.5" stroke-width="0.25"></circle>
<path d="M 50 2 V 6" stroke="#0df259" stroke-linecap="round" stroke-width="2"></path>
<path d="M 98 50 H 94" stroke="currentColor" stroke-linecap="round" stroke-width="1.5"></path>
<path d="M 50 98 V 94" stroke="currentColor" stroke-linecap="round" stroke-width="1.5"></path>
<path d="M 2 50 H 6" stroke="currentColor" stroke-linecap="round" stroke-width="1.5"></path>
</svg>
<div class="absolute w-48 h-48 rounded-full border border-white/10 bg-[#050505] flex items-center justify-center shadow-[inset_0_0_30px_rgba(0,0,0,1)]">
<div class="flex flex-col items-center z-10">
<div class="flex items-start translate-x-1">
<span class="text-5xl font-mono font-bold text-white tracking-tighter">285</span>
<span class="text-xl font-mono text-primary font-bold mt-1">°</span>
</div>
<span class="text-lg font-bold text-primary tracking-[0.3em] -mt-1">NW</span>
</div>
<div class="absolute w-full h-[1px] bg-white/10"></div>
<div class="absolute h-full w-[1px] bg-white/10"></div>
<svg class="absolute inset-0 w-full h-full rotate-45" viewBox="0 0 100 100">
<path d="M 20 50 A 30 30 0 0 1 80 50" fill="none" stroke="#0df259" stroke-opacity="0.2" stroke-width="1"></path>
<path d="M 20 50 A 30 30 0 0 0 80 50" fill="none" stroke="white" stroke-opacity="0.1" stroke-width="1"></path>
</svg>
</div>
<div class="absolute -top-1">
<div class="w-0 h-0 border-l-[6px] border-l-transparent border-r-[6px] border-r-transparent border-b-[10px] border-b-primary filter drop-shadow-[0_0_4px_#0df259]"></div>
</div>
</div>
<div class="grid grid-cols-2 gap-4 w-full">
<button class="relative bg-danger/10 hover:bg-danger/20 border border-danger/30 hover:border-danger/60 rounded-xl py-4 flex flex-col items-center justify-center gap-2 transition-all active:scale-[0.98]">
<span class="material-symbols-outlined text-danger text-2xl mb-1">sos</span>
<span class="text-xs font-bold text-white uppercase tracking-wider">Send SOS</span>
<div class="absolute top-3 right-3 w-1.5 h-1.5 rounded-full bg-danger animate-pulse"></div>
</button>
<button class="relative bg-white/5 hover:bg-white/10 border border-white/10 hover:border-white/30 rounded-xl py-4 flex flex-col items-center justify-center gap-2 transition-all active:scale-[0.98]">
<span class="material-symbols-outlined text-white text-2xl mb-1">wb_sunny</span>
<span class="text-xs font-bold text-white uppercase tracking-wider">Signal Mirror</span>
</button>
</div>
</div>
</div>
<div class="h-6 w-full"></div>
</div>
</div>
</body></html>

<!-- PANDU Navigation Map -->
<!DOCTYPE html>
<html class="dark" lang="en"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>PANDU Navigation Map</title>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<script id="tailwind-config">
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    colors: {
                        "primary": "#0df259",
                        "danger": "#ff3b30",
                        "background-light": "#f5f8f6",
                        "background-dark": "#050505",
                        "surface-dark": "#121212",
                    },
                    fontFamily: {
                        "display": ["Space Grotesk", "sans-serif"]
                    },
                    borderRadius: {"DEFAULT": "0.25rem", "lg": "0.5rem", "xl": "0.75rem", "2xl": "1rem", "full": "9999px"},
                    animation: {
                        'pulse-slow': 'pulse 3s cubic-bezier(0.4, 0, 0.6, 1) infinite',
                    }
                },
            },
        }
    </script>
<style>@import url("https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300;400;500;600;700&display=swap");
    .map-texture {
        background-image: radial-gradient(circle at 50% 50%, rgba(13, 242, 89, 0.05) 0%, transparent 50%), repeating-linear-gradient(0deg, transparent, transparent 49px, rgba(255, 255, 255, 0.03) 50px), repeating-linear-gradient(90deg, transparent, transparent 49px, rgba(255, 255, 255, 0.03) 50px);
        background-size: 100% 100%, 100px 100px, 100px 100px
        }
    .contour-lines {
        background-image: url(https://lh3.googleusercontent.com/aida-public/AB6AXuBErJm65Fwc_dGTQ4E6Fu2YfCpI4zjj_TxmZStQE-2Ll1REFvGr1Ae5-_MwcREp68LWzOpO_LZP2lmsO0HiiUMeZxIwWAee0AGOpOh-AOxr8uqay4is5oMe27Ab1802NwGZ9PBDJOmT2upM2CbddxSIuR1kLTxjD0wCMewgWodbJtxFJhOjpo7o6xwFCZw-tp01rdP5f0VxNwpeWZHLfE8_1HxYxfJTkUNaE2Xa4F9LT96eEzNx_1ZggLiOzfzP1FlNieW10juhWbhM);
        background-size: 200px 200px
        }
    .glass-panel {
        background: rgba(20, 20, 20, 0.6);
        backdrop-filter: blur(12px);
        -webkit-backdrop-filter: blur(12px);
        border: 1px solid rgba(255, 255, 255, 0.1)
        }
    .danger-glow {
        box-shadow: inset 0 0 50px 20px rgba(255, 59, 48, 0.15);
        animation: breathe 2s infinite alternate
        }
    @keyframes breathe {
        from {
            box-shadow: inset 0 0 40px 10px rgba(255, 59, 48, 0.1);
            } to {
            box-shadow: inset 0 0 80px 30px rgba(255, 59, 48, 0.25);
            }
        }</style>
<style>
        body {
          min-height: max(884px, 100dvh);
        }
    </style>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
  </head>
<body class="font-display bg-background-light dark:bg-background-dark text-white h-screen w-full overflow-hidden select-none">
<div class="relative h-full w-full flex flex-col group/design-root danger-glow">
<div class="absolute top-0 w-full h-12 z-50 flex justify-between items-center px-6 pt-2 pointer-events-none">
<span class="text-xs font-medium text-white/70">09:41</span>
<div class="flex gap-1">
<span class="material-symbols-outlined text-[18px] text-white/70">signal_cellular_alt</span>
<span class="material-symbols-outlined text-[18px] text-white/70">wifi</span>
<span class="material-symbols-outlined text-[18px] text-white/70">battery_5_bar</span>
</div>
</div>
<div class="absolute inset-0 z-0 bg-background-dark overflow-hidden">
<div class="absolute inset-0 bg-cover bg-center opacity-40 mix-blend-overlay" data-alt="Dark abstract topographic map texture with contour lines" data-location="Swiss Alps" style="background-image: url('https://lh3.googleusercontent.com/aida-public/AB6AXuB5_fngukaYSei2RKSleWGAd47GTa5s3B4Bqj7Rwbicd31-bRrOD8QCSMO3nLq7hGs1G6iOL8fwVFoZYdHEEDwg9npzHfIclR88JRbeR9dgIBnD_zGpOm9UBDeHbWnHN6Tekg0XmV_8s1uOdjkJrrKHOOejxGdDdXBnnLZf7SnlQwWM3Fpw9e3ig8KOfiBzON6C7vTmgSVVMwJZLHDW-lg0n7nhG1NBSP2XaJB5IPzI9ssoj5bnJ4ZCTX3xH1YEW5zwqwwJT-m8xz0s');">
</div>
<div class="absolute inset-0 map-texture opacity-80"></div>
<div class="absolute inset-0 contour-lines opacity-30 rotate-12 scale-150"></div>
<svg class="absolute inset-0 w-full h-full pointer-events-none" style="filter: drop-shadow(0 0 8px rgba(13, 242, 89, 0.6));">
<path d="M -50 100 Q 100 400 200 300 T 500 800" fill="none" opacity="0.4" stroke="#0df259" stroke-dasharray="8 4" stroke-width="4"></path>
<path d="M 200 300 L 180 500 L 220 550" fill="none" stroke="#ff3b30" stroke-dasharray="4 2" stroke-width="4"></path>
</svg>
<div class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-32 h-32 flex items-center justify-center pointer-events-none">
<div class="absolute w-full h-full bg-primary/20 rounded-full animate-ping opacity-20"></div>
<div class="absolute w-16 h-16 bg-primary/10 rounded-full animate-pulse"></div>
<div class="relative z-10 w-0 h-0 border-l-[10px] border-l-transparent border-r-[10px] border-r-transparent border-b-[20px] border-b-primary filter drop-shadow-[0_0_10px_rgba(13,242,89,0.8)]"></div>
<div class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-full w-[120px] h-[180px] bg-gradient-to-t from-primary/20 to-transparent -mt-2 clip-path-polygon transform -rotate-45 origin-bottom" style="clip-path: polygon(50% 100%, 0 0, 100% 0);"></div>
</div>
</div>
<div class="relative z-10 pt-16 px-4 flex justify-between items-start gap-2">
<div class="glass-panel rounded-full h-10 px-4 flex items-center gap-2 shadow-lg">
<span class="material-symbols-outlined text-primary text-[20px]">landscape</span>
<div class="flex flex-col leading-none">
<span class="text-[10px] text-gray-400 font-bold tracking-wider uppercase">Alt</span>
<span class="text-sm font-bold text-white font-mono">2,450<span class="text-xs font-normal text-gray-400 ml-0.5">m</span></span>
</div>
</div>
<div class="glass-panel rounded-full h-10 px-4 flex items-center gap-2 shadow-lg min-w-[110px] justify-center">
<span class="material-symbols-outlined text-primary text-[20px]">explore</span>
<span class="text-sm font-bold text-white font-mono tracking-wide">285° NW</span>
</div>
<div class="glass-panel rounded-full h-10 px-4 flex items-center gap-2 shadow-lg">
<span class="material-symbols-outlined text-primary text-[20px]">my_location</span>
<div class="flex flex-col leading-none">
<span class="text-[10px] text-gray-400 font-bold tracking-wider uppercase">GPS</span>
<span class="text-sm font-bold text-white font-mono">±3<span class="text-xs font-normal text-gray-400 ml-0.5">m</span></span>
</div>
</div>
</div>
<div class="absolute right-4 top-1/2 -translate-y-1/2 z-10 flex flex-col gap-3">
<button class="glass-panel w-12 h-12 rounded-xl flex items-center justify-center text-white active:bg-white/10 transition-colors shadow-lg">
<span class="material-symbols-outlined">add</span>
</button>
<button class="glass-panel w-12 h-12 rounded-xl flex items-center justify-center text-white active:bg-white/10 transition-colors shadow-lg">
<span class="material-symbols-outlined">remove</span>
</button>
<button class="glass-panel w-12 h-12 rounded-xl flex items-center justify-center text-primary active:bg-white/10 transition-colors shadow-lg mt-4 border-primary/30">
<span class="material-symbols-outlined">near_me</span>
</button>
<button class="glass-panel w-12 h-12 rounded-xl flex items-center justify-center text-white active:bg-white/10 transition-colors shadow-lg">
<span class="material-symbols-outlined">layers</span>
</button>
</div>
<div class="absolute top-32 w-full flex justify-center z-10 pointer-events-none">
<div class="bg-danger/90 backdrop-blur-md px-4 py-1.5 rounded-full border border-red-500/50 shadow-[0_0_20px_rgba(255,59,48,0.4)] flex items-center gap-2 animate-pulse">
<span class="material-symbols-outlined text-white text-[18px]">warning</span>
<span class="text-xs font-bold tracking-widest text-white uppercase">Off Trail Detected</span>
</div>
</div>
<div class="absolute bottom-0 w-full z-20">
<div class="mx-2 mb-2 bg-surface-dark/95 backdrop-blur-xl rounded-t-[2rem] rounded-b-[2rem] border border-white/5 shadow-2xl overflow-hidden">
<div class="w-full flex justify-center pt-3 pb-1">
<div class="w-12 h-1 rounded-full bg-white/20"></div>
</div>
<div class="px-5 pb-6 pt-2">
<div class="flex justify-between items-end mb-5 px-1">
<div>
<h2 class="text-white text-lg font-bold uppercase tracking-wide leading-none">Environment</h2>
<p class="text-[10px] text-primary font-mono tracking-widest mt-1 opacity-80">SENSORS ONLINE /// 46°12'N 07°54'E</p>
</div>
<div class="flex items-center gap-2 bg-white/5 px-2 py-1 rounded-lg border border-white/5">
<span class="material-symbols-outlined text-white/50 text-[18px]">thermostat</span>
<span class="text-white font-mono font-bold text-sm">12°C</span>
</div>
</div>
<div class="grid grid-cols-2 gap-3 mb-4">
<div class="bg-gradient-to-br from-white/10 to-transparent border border-white/10 rounded-2xl p-3.5 relative overflow-hidden group">
<div class="absolute top-0 right-0 w-12 h-12 bg-primary/5 rounded-bl-3xl"></div>
<div class="flex justify-between items-start mb-2 relative z-10">
<span class="text-[10px] text-gray-400 uppercase tracking-widest font-bold">Pressure</span>
<span class="material-symbols-outlined text-primary text-[18px]">air</span>
</div>
<div class="flex items-baseline gap-1 relative z-10">
<span class="text-2xl font-bold font-mono text-white tracking-tighter">1,018</span>
<span class="text-[10px] text-gray-500 font-mono uppercase">hPa</span>
</div>
<div class="w-full h-1.5 bg-black/40 mt-3 rounded-full overflow-hidden relative border border-white/5">
<div class="h-full bg-primary w-[70%] shadow-[0_0_8px_rgba(13,242,89,0.5)]"></div>
</div>
<div class="flex justify-between mt-1.5">
<span class="text-[9px] text-gray-600 font-mono">Low</span>
<span class="text-[9px] text-gray-600 font-mono">High</span>
</div>
</div>
<div class="bg-gradient-to-br from-white/10 to-transparent border border-white/10 rounded-2xl p-3.5 relative overflow-hidden">
<div class="absolute top-0 right-0 w-12 h-12 bg-orange-500/5 rounded-bl-3xl"></div>
<div class="flex justify-between items-start mb-2 relative z-10">
<span class="text-[10px] text-gray-400 uppercase tracking-widest font-bold">UV Index</span>
<span class="material-symbols-outlined text-orange-400 text-[18px]">wb_sunny</span>
</div>
<div class="flex items-baseline gap-2 relative z-10">
<span class="text-2xl font-bold font-mono text-white tracking-tighter">04</span>
<span class="text-[10px] text-orange-400 font-mono border border-orange-400/30 px-1.5 py-0.5 rounded uppercase">Moderate</span>
</div>
<div class="flex gap-1 mt-4">
<div class="h-1.5 flex-1 bg-primary rounded-full"></div>
<div class="h-1.5 flex-1 bg-primary rounded-full"></div>
<div class="h-1.5 flex-1 bg-orange-400 rounded-full shadow-[0_0_8px_rgba(251,146,60,0.5)]"></div>
<div class="h-1.5 flex-1 bg-white/10 rounded-full"></div>
<div class="h-1.5 flex-1 bg-white/10 rounded-full"></div>
</div>
</div>
</div>
<div class="bg-white/5 border border-white/10 rounded-2xl p-4 mb-5 flex items-center justify-between relative overflow-hidden">
<div class="absolute inset-0 opacity-10" style="background-image: linear-gradient(0deg, transparent 24%, rgba(255, 255, 255, .3) 25%, rgba(255, 255, 255, .3) 26%, transparent 27%, transparent 74%, rgba(255, 255, 255, .3) 75%, rgba(255, 255, 255, .3) 76%, transparent 77%, transparent), linear-gradient(90deg, transparent 24%, rgba(255, 255, 255, .3) 25%, rgba(255, 255, 255, .3) 26%, transparent 27%, transparent 74%, rgba(255, 255, 255, .3) 75%, rgba(255, 255, 255, .3) 76%, transparent 77%, transparent); background-size: 30px 30px;"></div>
<div class="flex flex-col relative z-10 pl-1">
<span class="text-[10px] text-gray-400 uppercase tracking-widest mb-1 font-bold">Sunset Approach</span>
<div class="flex items-center gap-2">
<span class="text-xl font-bold font-mono text-white">18:42</span>
<span class="text-xs text-primary font-mono bg-primary/10 px-1.5 rounded border border-primary/20">-42m</span>
</div>
</div>
<div class="h-10 flex-1 ml-6 mr-2 relative">
<div class="absolute bottom-0 w-full h-[1px] bg-white/20"></div>
<div class="absolute bottom-0 left-0 w-full h-full border-t-2 border-r-2 border-l-2 border-white/10 rounded-t-full border-dashed"></div>
<div class="absolute bottom-1 left-[75%] -translate-x-1/2 flex flex-col items-center gap-1">
<div class="w-3 h-3 bg-orange-400 rounded-full shadow-[0_0_12px_rgba(251,146,60,0.8)] border border-orange-200"></div>
<div class="h-6 w-[1px] border-l border-dashed border-orange-400/50"></div>
</div>
</div>
</div>
<div class="mb-2">
<div class="flex items-center gap-2 mb-3 px-1">
<span class="material-symbols-outlined text-primary text-[14px]">bolt</span>
<span class="text-[10px] font-bold text-white/60 uppercase tracking-widest">Survival Lighting</span>
</div>
<div class="grid grid-cols-2 gap-3">
<button class="bg-white/5 hover:bg-white/10 active:bg-white/20 border border-white/10 rounded-xl p-3 flex items-center gap-3 transition-all relative overflow-hidden group">
<div class="w-10 h-10 rounded-full bg-white/10 flex items-center justify-center group-active:scale-95 transition-transform">
<span class="material-symbols-outlined text-white text-[20px]">flashlight_on</span>
</div>
<div class="flex flex-col items-start">
<span class="text-xs font-bold text-white uppercase tracking-wider">Flashlight</span>
<span class="text-[10px] text-gray-500">Off</span>
</div>
<div class="absolute right-3 w-8 h-4 bg-white/10 rounded-full p-0.5">
<div class="w-3 h-3 bg-gray-500 rounded-full"></div>
</div>
</button>
<button class="bg-danger/10 hover:bg-danger/20 border border-danger/30 rounded-xl p-3 flex items-center gap-3 transition-all group relative overflow-hidden">
<div class="w-10 h-10 rounded-full bg-danger/20 flex items-center justify-center border border-danger/20 group-hover:border-danger/50">
<span class="material-symbols-outlined text-danger text-[20px] group-hover:animate-pulse">flourescent</span>
</div>
<div class="flex flex-col items-start relative z-10">
<span class="text-xs font-bold text-danger uppercase tracking-wider group-hover:text-white transition-colors">Strobe SOS</span>
<span class="text-[10px] text-danger/60 group-hover:text-white/60 transition-colors">Emergency</span>
</div>
</button>
</div>
</div>
</div>
</div>
<div class="h-6 w-full"></div>
</div>
</div>

</body></html>