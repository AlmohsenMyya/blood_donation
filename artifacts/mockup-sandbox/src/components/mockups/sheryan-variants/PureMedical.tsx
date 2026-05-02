import React from 'react';
import { Bell, Droplet, History, Home, User, FileText, Activity, CheckCircle2 } from 'lucide-react';

export function PureMedical() {
  return (
    <div 
      style={{
        width: '390px', 
        height: '844px', 
        overflowY: 'auto', 
        position: 'relative', 
        direction: 'rtl', 
        fontFamily: '"Inter", sans-serif'
      }} 
      className="bg-white text-slate-900 border border-slate-200 mx-auto overflow-hidden flex flex-col"
    >
      {/* Top AppBar */}
      <header className="flex items-center justify-between p-6 bg-white border-b border-slate-100 shrink-0">
        <div className="flex items-center gap-3">
          <div className="w-12 h-12 rounded-full bg-slate-100 flex items-center justify-center text-[#0891B2] font-bold text-lg border border-slate-200">
            أ.م
          </div>
          <div>
            <p className="text-xs text-slate-500 font-medium mb-0.5">مرحباً بعودتك</p>
            <h1 className="text-lg font-bold text-slate-900 leading-none">أحمد محمد</h1>
          </div>
        </div>
        <div className="relative">
          <button className="w-10 h-10 rounded-full border border-slate-200 flex items-center justify-center text-slate-600 bg-white hover:bg-slate-50 transition-colors">
            <Bell size={20} />
          </button>
          <span className="absolute top-0 right-0 w-3 h-3 bg-red-500 border-2 border-white rounded-full"></span>
        </div>
      </header>

      {/* Main Scrollable Content */}
      <main className="flex-1 overflow-y-auto pb-24 px-6 pt-6 flex flex-col gap-8 bg-white">
        
        {/* Top Section: Blood Group & Profile */}
        <section className="flex items-center gap-4">
          {/* Blood Group Badge */}
          <div className="w-24 h-24 rounded-2xl border border-slate-200 bg-white flex flex-col items-center justify-center relative shrink-0">
            <span className="text-3xl font-black text-red-600 tracking-tighter">A+</span>
            <span className="text-[10px] text-slate-500 font-medium uppercase tracking-wider mt-1">فصيلة الدم</span>
            <div className="absolute -bottom-2 -right-2 bg-white rounded-full p-0.5">
              <CheckCircle2 size={20} className="text-[#0891B2] fill-white" />
            </div>
          </div>

          {/* Profile Completion */}
          <div className="flex-1 h-24 rounded-2xl border border-slate-200 bg-white p-4 flex flex-col justify-center">
            <div className="flex justify-between items-end mb-3">
              <span className="text-sm font-semibold text-slate-800">اكتمال الملف</span>
              <span className="text-xl font-bold text-[#0891B2]">65%</span>
            </div>
            <div className="w-full h-2 bg-slate-100 rounded-full overflow-hidden">
              <div className="h-full bg-[#0891B2] rounded-full" style={{ width: '65%' }}></div>
            </div>
            <p className="text-[10px] text-slate-500 mt-2">أكمل ملفك الطبي لتسريع عملية التبرع</p>
          </div>
        </section>

        {/* Quick Actions */}
        <section>
          <h2 className="text-sm font-bold text-slate-900 mb-4 px-1">إجراءات سريعة</h2>
          <div className="grid grid-cols-3 gap-3">
            <button className="flex flex-col items-center justify-center gap-2 p-4 rounded-2xl bg-red-600 text-white shadow-sm hover:bg-red-700 transition-colors">
              <Droplet size={24} className="fill-current" />
              <span className="text-xs font-semibold">تبرع بالدم</span>
            </button>
            <button className="flex flex-col items-center justify-center gap-2 p-4 rounded-2xl bg-white border border-[#0891B2] text-[#0891B2] hover:bg-slate-50 transition-colors">
              <Activity size={24} />
              <span className="text-xs font-semibold">طلب دم</span>
            </button>
            <button className="flex flex-col items-center justify-center gap-2 p-4 rounded-2xl bg-white border border-slate-200 text-slate-600 hover:bg-slate-50 transition-colors">
              <History size={24} />
              <span className="text-xs font-semibold">سجلي</span>
            </button>
          </div>
        </section>

        {/* Recent Activity */}
        <section>
          <div className="flex justify-between items-center mb-4 px-1">
            <h2 className="text-sm font-bold text-slate-900">النشاط الأخير</h2>
            <button className="text-xs font-semibold text-[#0891B2]">عرض الكل</button>
          </div>
          
          <div className="flex flex-col gap-3">
            {/* Activity Item 1 */}
            <div className="flex items-center p-4 bg-white border border-slate-100 rounded-2xl">
              <div className="w-10 h-10 rounded-full bg-slate-50 flex items-center justify-center shrink-0 border border-slate-100 ml-4">
                <Droplet size={18} className="text-red-500" />
              </div>
              <div className="flex-1">
                <h3 className="text-sm font-semibold text-slate-900">تبرع ناجح</h3>
                <p className="text-xs text-slate-500 mt-0.5">مستشفى الملك فهد</p>
              </div>
              <span className="text-[10px] font-medium text-slate-400">منذ يومين</span>
            </div>

            {/* Activity Item 2 */}
            <div className="flex items-center p-4 bg-white border border-slate-100 rounded-2xl">
              <div className="w-10 h-10 rounded-full bg-slate-50 flex items-center justify-center shrink-0 border border-slate-100 ml-4">
                <Activity size={18} className="text-[#0891B2]" />
              </div>
              <div className="flex-1">
                <h3 className="text-sm font-semibold text-slate-900">حملة تبرع قريبة</h3>
                <p className="text-xs text-slate-500 mt-0.5">يوجد نقص في فصيلة A+ بالقرب منك</p>
              </div>
              <span className="text-[10px] font-medium text-slate-400">الآن</span>
            </div>
            
             {/* Activity Item 3 */}
             <div className="flex items-center p-4 bg-white border border-slate-100 rounded-2xl">
              <div className="w-10 h-10 rounded-full bg-slate-50 flex items-center justify-center shrink-0 border border-slate-100 ml-4">
                <CheckCircle2 size={18} className="text-green-500" />
              </div>
              <div className="flex-1">
                <h3 className="text-sm font-semibold text-slate-900">تحديث الملف الطبي</h3>
                <p className="text-xs text-slate-500 mt-0.5">تم التحقق من الفحوصات الأخيرة</p>
              </div>
              <span className="text-[10px] font-medium text-slate-400">منذ أسبوع</span>
            </div>
          </div>
        </section>

      </main>

      {/* Bottom Navigation */}
      <nav className="absolute bottom-0 w-full bg-white border-t border-slate-200 pb-safe pt-2 px-6 pb-6 shrink-0 z-10">
        <div className="flex justify-between items-center">
          <button className="flex flex-col items-center gap-1 text-[#0891B2]">
            <Home size={22} className="stroke-[2.5px]" />
            <span className="text-[10px] font-semibold">الرئيسية</span>
          </button>
          <button className="flex flex-col items-center gap-1 text-slate-400 hover:text-slate-600 transition-colors">
            <FileText size={22} />
            <span className="text-[10px] font-medium">الطلبات</span>
          </button>
          <button className="flex flex-col items-center gap-1 text-slate-400 hover:text-slate-600 transition-colors relative -top-3">
            <div className="w-12 h-12 bg-red-50 text-red-600 rounded-full flex items-center justify-center mb-1 border border-red-100">
               <Droplet size={24} className="fill-current" />
            </div>
            <span className="text-[10px] font-medium text-slate-500">تبرع</span>
          </button>
          <button className="flex flex-col items-center gap-1 text-slate-400 hover:text-slate-600 transition-colors">
            <Bell size={22} />
            <span className="text-[10px] font-medium">إشعارات</span>
          </button>
          <button className="flex flex-col items-center gap-1 text-slate-400 hover:text-slate-600 transition-colors">
            <User size={22} />
            <span className="text-[10px] font-medium">حسابي</span>
          </button>
        </div>
      </nav>
    </div>
  );
}
