import React from "react";
import { 
  Bell, 
  Droplet, 
  Activity, 
  Clock, 
  Home, 
  Search, 
  PlusCircle, 
  User, 
  CheckCircle2, 
  ArrowLeft,
  ChevronLeft,
  HeartPulse
} from "lucide-react";

export function MidnightPulse() {
  return (
    <div 
      style={{
        width: '390px', 
        height: '844px', 
        overflowY: 'auto', 
        position: 'relative',
        backgroundColor: '#0F172A', // Slate 900
        color: '#FFFFFF',
        fontFamily: "'Space Grotesk', sans-serif"
      }}
      className="flex flex-col antialiased overflow-x-hidden"
      dir="rtl"
    >
      <style>
        {`
          @import url('https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;500;600;700&display=swap');
          
          /* Custom scrollbar for webkit */
          ::-webkit-scrollbar {
            width: 0px;
            background: transparent;
          }
        `}
      </style>

      {/* Header / App Bar */}
      <header className="relative pt-12 pb-6 px-6 bg-[#1E293B] border-b border-[#334155] z-10">
        {/* Geometric background pattern overlay */}
        <div className="absolute inset-0 opacity-10 pointer-events-none overflow-hidden flex items-center justify-center">
          <Droplet size={300} strokeWidth={0.5} className="text-[#FF1744] transform -translate-y-12 translate-x-12" />
        </div>

        <div className="flex justify-between items-center relative z-10">
          <div className="flex items-center gap-4">
            <div className="relative">
              <div className="w-12 h-12 rounded-full overflow-hidden border-2 border-[#FF1744]">
                <img 
                  src="/__mockup/images/ahmed-avatar.png" 
                  alt="Ahmed Avatar" 
                  className="w-full h-full object-cover bg-[#334155]"
                  onError={(e) => {
                    (e.target as HTMLImageElement).src = 'data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" width="100%" height="100%" viewBox="0 0 24 24" fill="%23334155" stroke="%2394A3B8" stroke-width="1" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="8" r="5"/><path d="M20 21a8 8 0 0 0-16 0"/></svg>';
                  }}
                />
              </div>
            </div>
            <div>
              <p className="text-sm text-slate-400 font-medium">مرحباً بعودتك</p>
              <h1 className="text-xl font-bold tracking-tight">أحمد محمد</h1>
            </div>
          </div>
          
          <button className="w-10 h-10 flex items-center justify-center bg-[#0F172A] border border-slate-700 rounded-sm relative">
            <Bell size={20} className="text-white" />
            <span className="absolute top-2 right-2 w-2.5 h-2.5 bg-[#FF1744] rounded-full border-2 border-[#0F172A]"></span>
          </button>
        </div>
      </header>

      {/* Main Content Scrollable Area */}
      <main className="flex-1 pb-28 pt-6 px-6 flex flex-col gap-8">
        
        {/* Top Section: Blood Group & Profile Completion */}
        <div className="flex gap-6 items-center bg-[#1E293B] p-5 border border-slate-700 rounded-sm relative overflow-hidden">
          {/* Blood Group Badge */}
          <div className="flex-shrink-0 flex flex-col items-center justify-center w-20 h-20 bg-[#FF1744] rounded-sm relative shadow-[4px_4px_0px_#000]">
            <span className="text-3xl font-bold text-white tracking-tighter">A+</span>
            <div className="absolute -bottom-2 -left-2 bg-[#0F172A] rounded-full p-1 border border-slate-700">
              <CheckCircle2 size={16} className="text-[#10B981]" />
            </div>
          </div>

          {/* Profile Completion */}
          <div className="flex-1 flex flex-col gap-2">
            <div className="flex justify-between items-end">
              <h2 className="text-sm font-semibold uppercase tracking-wider text-slate-300">اكتمال الملف</h2>
              <span className="text-lg font-bold text-[#FF1744]">65%</span>
            </div>
            <div className="h-1.5 w-full bg-[#0F172A] rounded-none overflow-hidden">
              <div className="h-full bg-white" style={{ width: '65%' }}></div>
            </div>
            <p className="text-xs text-slate-400 mt-1">أكمل بياناتك الطبية للتبرع</p>
          </div>
        </div>

        {/* Stats Section */}
        <div className="grid grid-cols-2 gap-4">
          <div className="bg-[#1E293B] p-4 border border-slate-700 rounded-sm flex flex-col items-center justify-center text-center">
            <span className="text-4xl font-bold text-white mb-1">3</span>
            <span className="text-xs text-slate-400 uppercase tracking-widest">مرات التبرع</span>
          </div>
          <div className="bg-[#1E293B] p-4 border border-slate-700 rounded-sm flex flex-col items-center justify-center text-center">
            <span className="text-4xl font-bold text-[#FF1744] mb-1">9</span>
            <span className="text-xs text-slate-400 uppercase tracking-widest">أرواح أُنقذت</span>
          </div>
        </div>

        {/* Decorative Pulse Line */}
        <div className="w-full flex items-center justify-center opacity-50 my-2">
          <div className="h-px bg-slate-700 flex-1"></div>
          <HeartPulse size={24} className="text-[#FF1744] mx-4" strokeWidth={1.5} />
          <div className="h-px bg-slate-700 flex-1"></div>
        </div>

        {/* Quick Actions */}
        <div className="flex flex-col gap-3">
          <h3 className="text-sm font-semibold uppercase tracking-widest text-slate-400 mb-2">إجراءات سريعة</h3>
          
          <div className="grid grid-cols-2 gap-3">
            <button className="col-span-2 bg-[#FF1744] text-white p-4 rounded-sm font-bold flex items-center justify-between transition-transform active:scale-95 shadow-[4px_4px_0px_#000]">
              <div className="flex items-center gap-3">
                <Droplet fill="currentColor" size={24} />
                <span className="text-lg">تبرع بالدم الآن</span>
              </div>
              <ChevronLeft size={24} />
            </button>
            
            <button className="bg-transparent border-2 border-white text-white p-4 rounded-sm font-bold flex flex-col items-center justify-center gap-2 transition-transform active:scale-95 hover:bg-white hover:text-[#0F172A]">
              <Search size={24} />
              <span>طلب دم</span>
            </button>
            
            <button className="bg-[#1E293B] border border-slate-700 text-white p-4 rounded-sm font-bold flex flex-col items-center justify-center gap-2 transition-transform active:scale-95 hover:bg-slate-800">
              <Activity size={24} className="text-[#FF1744]" />
              <span>سجلي الطبي</span>
            </button>
          </div>
        </div>

        {/* Recent Activity */}
        <div className="flex flex-col gap-4">
          <div className="flex justify-between items-end mb-2">
            <h3 className="text-sm font-semibold uppercase tracking-widest text-slate-400">النشاط الأخير</h3>
            <button className="text-xs text-[#FF1744] font-medium uppercase tracking-wider">عرض الكل</button>
          </div>

          <div className="flex flex-col gap-3">
            {/* Activity Item 1 */}
            <div className="bg-[#1E293B] p-4 border-l-4 border-[#10B981] rounded-sm flex items-start gap-4 shadow-sm">
              <div className="w-10 h-10 rounded-sm bg-[#0F172A] border border-slate-700 flex items-center justify-center flex-shrink-0">
                <CheckCircle2 size={20} className="text-[#10B981]" />
              </div>
              <div className="flex-1">
                <h4 className="text-sm font-bold text-white mb-1">تمت الموافقة على التبرع</h4>
                <p className="text-xs text-slate-400 line-clamp-1">مستشفى الملك فهد التخصصي</p>
              </div>
              <span className="text-xs text-slate-500 font-medium">أمس</span>
            </div>

            {/* Activity Item 2 */}
            <div className="bg-[#1E293B] p-4 border-l-4 border-[#FF1744] rounded-sm flex items-start gap-4 shadow-sm">
              <div className="w-10 h-10 rounded-sm bg-[#FF1744] flex items-center justify-center flex-shrink-0">
                <Droplet size={20} className="text-white" />
              </div>
              <div className="flex-1">
                <h4 className="text-sm font-bold text-white mb-1">طلب عاجل: فصيلة A+</h4>
                <p className="text-xs text-slate-400 line-clamp-1">بنك الدم المركزي يبحث عن متبرعين</p>
              </div>
              <span className="text-xs text-slate-500 font-medium">2 يوم</span>
            </div>
          </div>
        </div>

      </main>

      {/* Bottom Navigation */}
      <nav className="absolute bottom-0 w-full bg-[#1E293B] border-t border-slate-700 px-6 py-4 pb-8 z-20">
        <div className="flex justify-between items-center">
          
          <button className="flex flex-col items-center gap-1.5 text-white relative group">
            <Home size={22} className="text-white" />
            <span className="text-[10px] font-medium opacity-100">الرئيسية</span>
            <div className="absolute -bottom-4 w-6 h-1 bg-[#FF1744] rounded-t-sm"></div>
          </button>
          
          <button className="flex flex-col items-center gap-1.5 text-slate-500 hover:text-slate-300 transition-colors">
            <Search size={22} />
            <span className="text-[10px] font-medium">الطلبات</span>
          </button>
          
          <button className="flex flex-col items-center justify-center w-14 h-14 bg-[#FF1744] rounded-sm text-white -mt-8 shadow-[0_4px_12px_rgba(255,23,68,0.4)] border-2 border-[#1E293B]">
            <Droplet size={26} fill="currentColor" />
          </button>
          
          <button className="flex flex-col items-center gap-1.5 text-slate-500 hover:text-slate-300 transition-colors relative">
            <Bell size={22} />
            <span className="text-[10px] font-medium">إشعارات</span>
            <span className="absolute top-0 right-2 w-2 h-2 bg-[#FF1744] rounded-full border-2 border-[#1E293B]"></span>
          </button>
          
          <button className="flex flex-col items-center gap-1.5 text-slate-500 hover:text-slate-300 transition-colors">
            <User size={22} />
            <span className="text-[10px] font-medium">حسابي</span>
          </button>
          
        </div>
      </nav>
      
    </div>
  );
}
