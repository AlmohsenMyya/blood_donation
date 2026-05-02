import React from 'react';
import { Bell, Heart, Droplets, History, Home, FileText, User, ChevronRight, CheckCircle2, HeartHandshake, ShieldCheck } from 'lucide-react';

export function WarmCommunity() {
  return (
    <div 
      className="font-sans antialiased text-slate-800"
      style={{
        width: '390px', 
        height: '844px', 
        overflowY: 'auto', 
        overflowX: 'hidden',
        position: 'relative',
        backgroundColor: '#FFF8F0',
        fontFamily: "'Nunito', sans-serif"
      }}
      dir="rtl"
    >
      <style>
        {`
          @import url('https://fonts.googleapis.com/css2?family=Nunito:wght@400;600;700;800&display=swap');
          
          .shadow-amber {
            box-shadow: 0 10px 25px -5px rgba(244, 140, 6, 0.15), 0 8px 10px -6px rgba(244, 140, 6, 0.1);
          }
          
          .hide-scrollbar::-webkit-scrollbar {
            display: none;
          }
          .hide-scrollbar {
            -ms-overflow-style: none;
            scrollbar-width: none;
          }
        `}
      </style>

      {/* Header Gradient */}
      <div 
        className="absolute top-0 left-0 right-0 h-64 rounded-b-[40px] z-0"
        style={{
          background: 'linear-gradient(135deg, #E85D04 0%, #F48C06 100%)'
        }}
      ></div>

      <div className="relative z-10 pb-24">
        {/* Top App Bar */}
        <div className="flex items-center justify-between px-6 pt-14 pb-6 text-white">
          <div className="flex items-center gap-3">
            <div className="w-12 h-12 rounded-full border-2 border-white/30 overflow-hidden bg-white/20 p-0.5">
              <img src="/__mockup/images/avatar_1.jpg" alt="User" className="w-full h-full rounded-full object-cover" />
            </div>
            <div>
              <p className="text-white/80 text-sm font-semibold">مرحباً أحمد</p>
              <h1 className="text-xl font-bold tracking-tight">كيف تشعر اليوم؟</h1>
            </div>
          </div>
          <button className="relative w-10 h-10 rounded-full bg-white/10 flex items-center justify-center backdrop-blur-sm">
            <Bell size={20} className="text-white" />
            <span className="absolute top-2 right-2 w-2.5 h-2.5 bg-red-500 rounded-full border-2 border-[#F48C06]"></span>
          </button>
        </div>

        {/* Stats Bubble */}
        <div className="px-6 mb-6">
          <div className="bg-white/10 backdrop-blur-md border border-white/20 rounded-[24px] p-4 flex items-center gap-4 text-white">
            <div className="w-12 h-12 rounded-full bg-white/20 flex items-center justify-center shrink-0">
              <HeartHandshake size={24} className="text-white" />
            </div>
            <div>
              <p className="font-bold text-lg leading-tight">بإمكانك إنقاذ 3 أشخاص اليوم!</p>
              <p className="text-white/80 text-sm mt-0.5">فصيلة دمك نادرة ومطلوبة بشدة</p>
            </div>
          </div>
        </div>

        {/* Profile Card */}
        <div className="px-6 mb-6">
          <div className="bg-white rounded-[24px] p-5 shadow-amber relative overflow-hidden">
            <div className="flex justify-between items-start mb-4">
              <div className="flex items-center gap-2 text-amber-500 font-bold bg-amber-50 px-3 py-1.5 rounded-full text-sm">
                <ShieldCheck size={16} />
                متبرع موثوق
              </div>
              
              <div className="text-center">
                <div className="w-16 h-16 rounded-full bg-gradient-to-br from-amber-400 to-coral-500 flex items-center justify-center mx-auto mb-1 shadow-md" style={{ background: 'linear-gradient(135deg, #F48C06, #E85D04)' }}>
                  <span className="text-2xl font-black text-white">A+</span>
                </div>
                <span className="text-xs font-bold text-slate-500">فصيلة الدم</span>
              </div>
            </div>

            <div className="space-y-2">
              <div className="flex justify-between text-sm">
                <span className="font-bold text-slate-700">اكتمال الملف الشخصي</span>
                <span className="font-bold" style={{ color: '#E85D04' }}>65%</span>
              </div>
              <div className="h-2.5 w-full bg-slate-100 rounded-full overflow-hidden">
                <div 
                  className="h-full rounded-full relative"
                  style={{ 
                    width: '65%',
                    background: 'linear-gradient(90deg, #F48C06, #E85D04)'
                  }}
                >
                  <div className="absolute top-0 bottom-0 left-0 right-0 bg-white/20 animate-pulse"></div>
                </div>
              </div>
              <p className="text-xs text-slate-400 mt-1">أكمل ملفك الصحي لتسريع عملية التبرع</p>
            </div>
          </div>
        </div>

        {/* Quick Actions */}
        <div className="px-6 mb-8">
          <h2 className="text-lg font-bold text-slate-800 mb-4">إجراءات سريعة</h2>
          <div className="flex gap-3">
            <button className="flex-1 bg-white rounded-[20px] p-4 shadow-amber flex flex-col items-center justify-center gap-3 border border-coral-100 transition-transform active:scale-95" style={{ borderColor: '#ffe8d6' }}>
              <div className="w-12 h-12 rounded-full flex items-center justify-center" style={{ backgroundColor: '#fff0e5', color: '#E85D04' }}>
                <Droplets size={24} />
              </div>
              <span className="font-bold text-sm">تبرع الآن</span>
            </button>
            
            <button className="flex-1 bg-white rounded-[20px] p-4 shadow-amber flex flex-col items-center justify-center gap-3 border border-coral-100 transition-transform active:scale-95" style={{ borderColor: '#ffe8d6' }}>
              <div className="w-12 h-12 rounded-full flex items-center justify-center" style={{ backgroundColor: '#fff0e5', color: '#E85D04' }}>
                <Heart size={24} />
              </div>
              <span className="font-bold text-sm">طلب دم</span>
            </button>
            
            <button className="flex-1 bg-white rounded-[20px] p-4 shadow-amber flex flex-col items-center justify-center gap-3 border border-coral-100 transition-transform active:scale-95" style={{ borderColor: '#ffe8d6' }}>
              <div className="w-12 h-12 rounded-full flex items-center justify-center bg-slate-50 text-slate-500">
                <History size={24} />
              </div>
              <span className="font-bold text-sm text-slate-600">سجلي</span>
            </button>
          </div>
        </div>

        {/* Community Section */}
        <div className="mb-8">
          <div className="px-6 flex justify-between items-center mb-4">
            <h2 className="text-lg font-bold text-slate-800">مجتمع المتبرعين قريب منك</h2>
            <button className="text-sm font-bold flex items-center" style={{ color: '#F48C06' }}>
              عرض الكل <ChevronRight size={16} />
            </button>
          </div>
          
          <div className="flex gap-4 px-6 overflow-x-auto hide-scrollbar pb-4 pt-1">
            {[1, 2, 3].map((i) => (
              <div key={i} className="min-w-[120px] bg-white rounded-[20px] p-3 shadow-amber text-center border border-slate-100">
                <div className="relative w-14 h-14 mx-auto mb-2">
                  <img src={`/__mockup/images/avatar_${i+1}.jpg`} className="w-full h-full rounded-full object-cover border-2 border-white shadow-sm" alt="Donor" />
                  <div className="absolute bottom-0 right-0 w-4 h-4 bg-green-500 border-2 border-white rounded-full"></div>
                </div>
                <p className="font-bold text-sm truncate">سارة {i}</p>
                <p className="text-xs text-slate-400">تبعد 2 كم</p>
                <div className="mt-2 text-[10px] font-bold bg-amber-50 text-amber-600 py-1 rounded-full w-max px-2 mx-auto">A+</div>
              </div>
            ))}
          </div>
        </div>

        {/* Recent Activity */}
        <div className="px-6 mb-6">
          <h2 className="text-lg font-bold text-slate-800 mb-4">النشاط الأخير</h2>
          <div className="bg-white rounded-[24px] p-1 shadow-amber border border-slate-100">
            
            <div className="p-4 flex items-center gap-4 border-b border-slate-50">
              <div className="w-10 h-10 rounded-full flex items-center justify-center shrink-0" style={{ backgroundColor: '#fff0e5', color: '#E85D04' }}>
                <CheckCircle2 size={20} />
              </div>
              <div className="flex-1">
                <p className="font-bold text-sm">تم التبرع بنجاح</p>
                <p className="text-xs text-slate-400">مستشفى الملك فهد • قبل يومين</p>
              </div>
            </div>

            <div className="p-4 flex items-center gap-4">
              <div className="w-10 h-10 rounded-full bg-blue-50 flex items-center justify-center text-blue-500 shrink-0">
                <Bell size={20} />
              </div>
              <div className="flex-1">
                <p className="font-bold text-sm">تذكير بموعد التبرع القادم</p>
                <p className="text-xs text-slate-400">يمكنك التبرع بعد 45 يوماً</p>
              </div>
            </div>

          </div>
        </div>
      </div>

      {/* Bottom Navigation */}
      <div className="absolute bottom-0 left-0 right-0 bg-white rounded-t-[30px] shadow-[0_-10px_30px_rgba(0,0,0,0.05)] px-6 py-4 z-50">
        <div className="flex justify-between items-center relative">
          
          <button className="flex flex-col items-center gap-1 w-14">
            <div className="w-12 h-10 flex items-center justify-center rounded-2xl" style={{ backgroundColor: '#fff0e5', color: '#E85D04' }}>
              <Home size={22} fill="currentColor" />
            </div>
            <span className="text-[10px] font-bold" style={{ color: '#E85D04' }}>الرئيسية</span>
          </button>
          
          <button className="flex flex-col items-center gap-1 w-14 text-slate-400">
            <div className="w-12 h-10 flex items-center justify-center rounded-2xl transition-colors hover:bg-slate-50">
              <FileText size={22} />
            </div>
            <span className="text-[10px] font-semibold">الطلبات</span>
          </button>
          
          <div className="w-14 flex justify-center -mt-8 relative z-10">
            <button className="w-14 h-14 rounded-full flex items-center justify-center text-white shadow-lg shadow-coral-500/30 transform transition-transform active:scale-95" style={{ background: 'linear-gradient(135deg, #F48C06, #E85D04)' }}>
              <Droplets size={24} fill="currentColor" />
            </button>
          </div>
          
          <button className="flex flex-col items-center gap-1 w-14 text-slate-400">
            <div className="w-12 h-10 flex items-center justify-center rounded-2xl transition-colors hover:bg-slate-50 relative">
              <Bell size={22} />
              <span className="absolute top-2 right-3 w-2 h-2 bg-red-500 rounded-full"></span>
            </div>
            <span className="text-[10px] font-semibold">تنبيهات</span>
          </button>
          
          <button className="flex flex-col items-center gap-1 w-14 text-slate-400">
            <div className="w-12 h-10 flex items-center justify-center rounded-2xl transition-colors hover:bg-slate-50">
              <User size={22} />
            </div>
            <span className="text-[10px] font-semibold">حسابي</span>
          </button>
          
        </div>
      </div>
    </div>
  );
}
