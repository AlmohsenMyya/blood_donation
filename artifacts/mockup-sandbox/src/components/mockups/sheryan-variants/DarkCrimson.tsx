import React from 'react';
import { Bell, CheckCircle2, Droplet, HandHeart, History, Home, User, Bell as BellIcon, Activity, ChevronLeft } from 'lucide-react';

export function DarkCrimson() {
  return (
    <div 
      className="font-sans antialiased bg-[#0D0D0D] text-gray-100 flex flex-col"
      style={{ 
        width: '390px', 
        height: '844px', 
        overflowY: 'auto', 
        position: 'relative',
        direction: 'rtl' 
      }}
    >
      <style>{`
        @import url('https://fonts.googleapis.com/css2?family=Rajdhani:wght@400;500;600;700&display=swap');
        
        .font-rajdhani {
          font-family: 'Rajdhani', sans-serif;
        }

        .neon-glow {
          box-shadow: 0 0 15px rgba(204, 0, 0, 0.4);
        }
        
        .neon-glow-strong {
          box-shadow: 0 0 25px rgba(204, 0, 0, 0.6);
        }

        .glass-card {
          background: rgba(20, 10, 10, 0.6);
          backdrop-filter: blur(12px);
          border: 1px solid rgba(204, 0, 0, 0.2);
        }
        
        .hide-scrollbar::-webkit-scrollbar {
          display: none;
        }
      `}</style>

      {/* Header Section */}
      <div className="relative pt-12 pb-24 px-6 rounded-b-[40px] overflow-hidden shrink-0 z-10" style={{ background: 'linear-gradient(135deg, #8B0000 0%, #3a0000 100%)' }}>
        {/* Subtle noise overlay could go here */}
        <div className="absolute inset-0 opacity-20 mix-blend-overlay pointer-events-none" style={{ backgroundImage: 'url("data:image/svg+xml,%3Csvg viewBox=%220 0 200 200%22 xmlns=%22http://www.w3.org/2000/svg%22%3E%3Cfilter id=%22noiseFilter%22%3E%3CfeTurbulence type=%22fractalNoise%22 baseFrequency=%220.65%22 numOctaves=%223%22 stitchTiles=%22stitch%22/%3E%3C/filter%3E%3Crect width=%22100%25%22 height=%22100%25%22 filter=%22url(%23noiseFilter)%22/%3E%3C/svg%3E")' }}></div>

        <div className="relative z-10 flex justify-between items-center mb-8">
          <div className="flex items-center gap-3">
            <div className="relative">
              <img 
                src="/__mockup/images/avatar-crimson.png" 
                alt="User Avatar" 
                className="w-12 h-12 rounded-full border-2 border-[#CC0000] object-cover"
              />
              <div className="absolute bottom-0 right-0 w-3 h-3 bg-green-500 rounded-full border-2 border-[#3a0000]"></div>
            </div>
            <div className="flex flex-col">
              <span className="text-sm text-red-200 opacity-80">مرحباً بعودتك</span>
              <h1 className="text-xl font-rajdhani font-bold tracking-wide">أحمد محمد</h1>
            </div>
          </div>
          
          <button className="relative p-2 rounded-full bg-black/20 backdrop-blur-sm border border-red-500/30">
            <Bell className="w-5 h-5 text-red-100" />
            <span className="absolute top-1.5 right-2 w-2 h-2 bg-[#CC0000] rounded-full animate-pulse neon-glow"></span>
          </button>
        </div>

        {/* Blood Badge & Completion */}
        <div className="relative z-10 flex items-center justify-between glass-card p-5 rounded-2xl">
          <div className="flex items-center gap-4">
            <div className="relative flex items-center justify-center w-16 h-16 rounded-full bg-gradient-to-br from-[#CC0000] to-[#5a0000] neon-glow-strong border border-red-400/30">
              <span className="font-rajdhani text-2xl font-bold">A+</span>
              <CheckCircle2 className="absolute -bottom-1 -right-1 w-5 h-5 text-white bg-green-500 rounded-full" />
            </div>
            <div>
              <div className="text-sm text-red-200 mb-1 font-rajdhani">فصيلة الدم (مؤكدة)</div>
              <div className="text-xs text-gray-400">جاهز للتبرع الآن</div>
            </div>
          </div>
        </div>
      </div>

      {/* Profile Completion Bar (Overlapping Header) */}
      <div className="px-6 -mt-6 relative z-20 shrink-0">
        <div className="glass-card p-4 rounded-xl flex flex-col gap-2">
          <div className="flex justify-between items-center text-sm">
            <span className="text-gray-300 font-rajdhani">اكتمال الملف الشخصي</span>
            <span className="text-[#CC0000] font-bold font-rajdhani text-lg drop-shadow-[0_0_5px_rgba(204,0,0,0.8)]">65%</span>
          </div>
          <div className="h-1.5 w-full bg-gray-800 rounded-full overflow-hidden">
            <div className="h-full bg-gradient-to-r from-[#8B0000] to-[#CC0000] rounded-full neon-glow" style={{ width: '65%' }}></div>
          </div>
          <div className="text-[10px] text-gray-500 mt-1">أكمل ملفك لتسريع عملية التبرع</div>
        </div>
      </div>

      {/* Main Content Area */}
      <div className="flex-1 px-6 pt-6 pb-24 overflow-y-auto hide-scrollbar space-y-6">
        
        {/* Quick Actions */}
        <div>
          <h2 className="text-lg font-rajdhani font-bold mb-4 flex items-center gap-2">
            <Activity className="w-5 h-5 text-[#CC0000]" />
            <span>إجراءات سريعة</span>
          </h2>
          <div className="grid grid-cols-3 gap-3">
            <button className="flex flex-col items-center justify-center gap-3 p-4 glass-card rounded-2xl border-red-500/40 hover:bg-red-900/20 transition-colors group relative overflow-hidden">
              <div className="absolute inset-0 bg-gradient-to-b from-[#CC0000]/10 to-transparent opacity-0 group-hover:opacity-100 transition-opacity"></div>
              <Droplet className="w-7 h-7 text-[#CC0000] drop-shadow-[0_0_8px_rgba(204,0,0,0.8)]" />
              <span className="text-xs font-medium">تبرع بالدم</span>
            </button>
            <button className="flex flex-col items-center justify-center gap-3 p-4 glass-card rounded-2xl hover:bg-red-900/20 transition-colors">
              <HandHeart className="w-7 h-7 text-gray-300" />
              <span className="text-xs font-medium">طلب دم</span>
            </button>
            <button className="flex flex-col items-center justify-center gap-3 p-4 glass-card rounded-2xl hover:bg-red-900/20 transition-colors">
              <History className="w-7 h-7 text-gray-300" />
              <span className="text-xs font-medium">سجلي</span>
            </button>
          </div>
        </div>

        {/* Recent Activity */}
        <div>
          <div className="flex justify-between items-center mb-4">
            <h2 className="text-lg font-rajdhani font-bold flex items-center gap-2">
              <History className="w-5 h-5 text-[#CC0000]" />
              <span>النشاط الأخير</span>
            </h2>
            <button className="text-xs text-[#CC0000] hover:text-red-400">عرض الكل</button>
          </div>
          
          <div className="space-y-3">
            <div className="glass-card p-4 rounded-xl flex items-center gap-4">
              <div className="w-10 h-10 rounded-full bg-green-500/10 border border-green-500/30 flex items-center justify-center shrink-0">
                <CheckCircle2 className="w-5 h-5 text-green-500" />
              </div>
              <div className="flex-1">
                <h3 className="text-sm font-medium">تبرع ناجح</h3>
                <p className="text-xs text-gray-400 mt-1">مستشفى الملك فهد</p>
              </div>
              <div className="text-xs text-gray-500 font-rajdhani">12 مايو</div>
            </div>

            <div className="glass-card p-4 rounded-xl flex items-center gap-4">
              <div className="w-10 h-10 rounded-full bg-red-500/10 border border-red-500/30 flex items-center justify-center shrink-0">
                <BellIcon className="w-5 h-5 text-[#CC0000]" />
              </div>
              <div className="flex-1">
                <h3 className="text-sm font-medium">طلب دم عاجل: A+</h3>
                <p className="text-xs text-gray-400 mt-1">يبعد 2.5 كم عن موقعك</p>
              </div>
              <div className="text-xs text-gray-500 font-rajdhani">أمس</div>
            </div>
            
            <div className="glass-card p-4 rounded-xl flex items-center gap-4 opacity-70">
              <div className="w-10 h-10 rounded-full bg-gray-800 border border-gray-700 flex items-center justify-center shrink-0">
                <Droplet className="w-5 h-5 text-gray-400" />
              </div>
              <div className="flex-1">
                <h3 className="text-sm font-medium">تحديث الحالة</h3>
                <p className="text-xs text-gray-400 mt-1">يمكنك التبرع بعد 14 يوم</p>
              </div>
              <div className="text-xs text-gray-500 font-rajdhani">20 أبريل</div>
            </div>
          </div>
        </div>

      </div>

      {/* Bottom Navigation */}
      <div className="absolute bottom-0 left-0 right-0 h-20 bg-[#050505] border-t border-red-900/30 flex justify-around items-center px-2 z-30 shrink-0">
        <div className="absolute top-0 left-0 right-0 h-px bg-gradient-to-r from-transparent via-[#CC0000]/50 to-transparent"></div>
        
        <button className="flex flex-col items-center gap-1.5 p-2 w-16 relative">
          <Home className="w-6 h-6 text-[#CC0000]" />
          <span className="text-[10px] text-[#CC0000] font-medium">الرئيسية</span>
          <div className="absolute -top-1 w-8 h-1 bg-[#CC0000] rounded-b-full neon-glow"></div>
        </button>
        
        <button className="flex flex-col items-center gap-1.5 p-2 w-16 opacity-60 hover:opacity-100 transition-opacity">
          <HandHeart className="w-6 h-6 text-gray-400" />
          <span className="text-[10px] text-gray-400">الطلبات</span>
        </button>
        
        <button className="flex flex-col items-center justify-center w-14 h-14 -mt-6 bg-gradient-to-br from-[#8B0000] to-[#CC0000] rounded-full border-[3px] border-[#0D0D0D] neon-glow-strong">
          <Droplet className="w-6 h-6 text-white" />
        </button>
        
        <button className="flex flex-col items-center gap-1.5 p-2 w-16 opacity-60 hover:opacity-100 transition-opacity relative">
          <BellIcon className="w-6 h-6 text-gray-400" />
          <span className="text-[10px] text-gray-400">إشعارات</span>
          <div className="absolute top-2 right-4 w-2 h-2 bg-[#CC0000] rounded-full border border-[#050505]"></div>
        </button>
        
        <button className="flex flex-col items-center gap-1.5 p-2 w-16 opacity-60 hover:opacity-100 transition-opacity">
          <User className="w-6 h-6 text-gray-400" />
          <span className="text-[10px] text-gray-400">حسابي</span>
        </button>
      </div>

    </div>
  );
}
