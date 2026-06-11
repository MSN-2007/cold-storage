import { useState, useEffect } from 'react';
import { 
  Snowflake, LayoutDashboard, Database, Box, Bell, BarChart2, Wrench, 
  Settings, HelpCircle, ChevronLeft, ChevronDown, Headset,
  RefreshCw, CheckCircle2, AlertTriangle, AlertCircle, WifiOff,
  Droplet, Thermometer, FlaskConical, Wind, Plus, Activity, ClipboardList,
  PlusCircle
} from 'lucide-react';

export default function App() {
  const [activeFilter, setActiveFilter] = useState('Total');
  const [lastUpdated, setLastUpdated] = useState(new Date().toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'}));
  const [isRefreshing, setIsRefreshing] = useState(false);

  const handleRefresh = () => {
    setIsRefreshing(true);
    setTimeout(() => {
      setLastUpdated(new Date().toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'}));
      setIsRefreshing(false);
    }, 800);
  };

  return (
    <div className="flex h-screen bg-background text-slate-800 font-sans overflow-hidden">
      <Sidebar />
      <div className="flex-1 flex flex-col overflow-y-auto">
        <Header 
          lastUpdated={lastUpdated} 
          onRefresh={handleRefresh} 
          isRefreshing={isRefreshing} 
        />
        <main className="p-8 max-w-7xl mx-auto w-full space-y-8">
          <MetricsRow activeFilter={activeFilter} onFilterChange={setActiveFilter} />
          <AlertsSection />
          <StorageGrid activeFilter={activeFilter} />
          <QuickActions />
        </main>
      </div>
    </div>
  );
}

function Sidebar() {
  const navItems = [
    { name: 'Dashboard', icon: LayoutDashboard, active: true },
    { name: 'My Storages', icon: Database },
    { name: 'Inventory', icon: Box },
    { name: 'Alerts', icon: Bell, badge: 8 },
    { name: 'Reports', icon: BarChart2 },
    { name: 'Technician', icon: Wrench },
    { name: 'Settings', icon: Settings },
    { name: 'FAQ', icon: HelpCircle },
  ];

  return (
    <div className="w-64 bg-sidebar text-slate-300 flex flex-col transition-all duration-300 flex-shrink-0 relative">
      <div className="p-6 flex items-center gap-3">
        <Snowflake className="text-accent w-8 h-8" />
        <span className="text-white text-xl font-bold tracking-wide">ColdSmart</span>
      </div>

      <nav className="flex-1 px-4 space-y-2 mt-4">
        {navItems.map((item) => (
          <button 
            key={item.name}
            className={`w-full flex items-center justify-between px-4 py-3 rounded-xl transition-colors ${
              item.active ? 'bg-accent text-white' : 'hover:bg-slate-800/50 hover:text-white'
            }`}
          >
            <div className="flex items-center gap-3">
              <item.icon className="w-5 h-5" />
              <span className="font-medium">{item.name}</span>
            </div>
            {item.badge && (
              <span className="bg-red-500 text-white text-xs font-bold px-2 py-0.5 rounded-full">
                {item.badge}
              </span>
            )}
          </button>
        ))}
      </nav>

      <div className="p-4 space-y-4">
        <button className="w-full bg-accent hover:bg-emerald-600 text-white flex items-center justify-center gap-2 py-3 rounded-xl font-bold transition-colors shadow-lg shadow-accent/20">
          <Plus className="w-5 h-5" />
          Add Goods
        </button>

        <div className="bg-slate-800/50 rounded-xl p-4 border border-slate-700/50 flex items-center justify-between cursor-pointer hover:bg-slate-800 transition-colors">
          <div className="flex items-center gap-3">
            <div className="bg-accent/20 p-2 rounded-lg">
              <Snowflake className="w-5 h-5 text-accent" />
            </div>
            <div>
              <p className="text-xs text-slate-400 font-medium">App Mode</p>
              <p className="text-white font-semibold text-sm">Simple</p>
            </div>
          </div>
          <ChevronDown className="w-4 h-4 text-slate-400" />
        </div>

        <div className="bg-slate-800/30 border border-slate-700/50 rounded-xl p-4">
          <p className="text-sm font-semibold text-white mb-1">Need Help?</p>
          <p className="text-xs text-slate-400 mb-3">Talk to our technician</p>
          <div className="flex items-center justify-between">
            <button className="text-xs bg-accent text-white px-4 py-1.5 rounded-lg font-medium hover:bg-emerald-600 transition">
              Contact Now
            </button>
            <Headset className="w-5 h-5 text-slate-500" />
          </div>
        </div>

        <div className="flex items-center justify-between text-xs text-slate-500 pt-2 px-2">
          <span>ColdSmart v1.0.0</span>
          <button className="hover:text-slate-300 transition-colors">
            <ChevronLeft className="w-4 h-4" />
          </button>
        </div>
      </div>
    </div>
  );
}

function Header({ lastUpdated, onRefresh, isRefreshing }) {
  return (
    <header className="bg-white border-b border-slate-200 px-8 py-5 flex items-start justify-between sticky top-0 z-10">
      <div>
        <h1 className="text-2xl font-bold text-slate-900 flex items-center gap-2">
          Good Morning, Ramesh! <span className="text-xl">👋</span>
        </h1>
        <p className="text-slate-500 text-sm mt-1">Here's what's happening in your cold storage today.</p>
      </div>

      <div className="flex flex-col items-end gap-3">
        <div className="flex items-center gap-6">
          <div className="flex items-center gap-4 text-slate-600">
            <button className="relative hover:text-slate-900 transition-colors">
              <Bell className="w-6 h-6" />
              <span className="absolute -top-1 -right-1 bg-red-500 border-2 border-white text-white text-[10px] font-bold px-1.5 py-0.5 rounded-full">8</span>
            </button>
            <button className="hover:text-slate-900 transition-colors">
              <HelpCircle className="w-6 h-6" />
            </button>
          </div>
          <div className="h-8 w-px bg-slate-200" />
          <div className="flex items-center gap-3 cursor-pointer hover:bg-slate-50 p-1.5 pr-2 rounded-xl border border-transparent hover:border-slate-200 transition-all">
            <img src="https://api.dicebear.com/7.x/avataaars/svg?seed=Ramesh" alt="Ramesh" className="w-10 h-10 rounded-full bg-blue-100" />
            <div>
              <p className="text-sm font-bold text-slate-900">Ramesh Kumar</p>
              <p className="text-xs text-slate-500">Owner</p>
            </div>
            <ChevronDown className="w-4 h-4 text-slate-400 ml-2" />
          </div>
        </div>
        <div className="flex items-center gap-2 text-xs text-slate-500 font-medium">
          <span>Last Updated: {lastUpdated}</span>
          <button onClick={onRefresh} className={`hover:text-slate-800 transition-colors ${isRefreshing ? 'animate-spin' : ''}`}>
            <RefreshCw className="w-3.5 h-3.5" />
          </button>
        </div>
      </div>
    </header>
  );
}

function MetricsRow({ activeFilter, onFilterChange }) {
  const metrics = [
    { label: 'Total Storages', count: 4, sub: 'All your cold storages', icon: Database, color: 'bg-blue-500', bg: 'bg-blue-50', text: 'text-blue-500', filter: 'Total' },
    { label: 'Healthy', count: 2, sub: 'Working fine', icon: CheckCircle2, color: 'bg-emerald-500', bg: 'bg-emerald-50', text: 'text-emerald-600', filter: 'Healthy' },
    { label: 'Warning', count: 1, sub: 'Needs attention', icon: AlertTriangle, color: 'bg-amber-500', bg: 'bg-amber-50', text: 'text-amber-600', filter: 'Warning' },
    { label: 'Critical', count: 1, sub: 'Immediate action', icon: AlertCircle, color: 'bg-red-500', bg: 'bg-red-50', text: 'text-red-600', filter: 'Critical' },
    { label: 'Offline', count: 0, sub: 'Not connected', icon: WifiOff, color: 'bg-slate-400', bg: 'bg-slate-100', text: 'text-slate-600', filter: 'Offline' },
  ];

  return (
    <div className="flex gap-4">
      {metrics.map((m) => (
        <button 
          key={m.label} 
          onClick={() => onFilterChange(m.filter)}
          className={`flex-1 bg-white p-5 rounded-2xl border text-left transition-all ${
            activeFilter === m.filter ? `border-${m.color.split('-')[1]}-500 shadow-md ring-1 ring-${m.color.split('-')[1]}-500/50` : 'border-slate-200 hover:border-slate-300 shadow-sm'
          }`}
        >
          <div className="flex items-start gap-4">
            <div className={`p-3 rounded-xl ${m.bg}`}>
              <m.icon className={`w-6 h-6 ${m.text}`} />
            </div>
            <div>
              <p className="text-3xl font-bold text-slate-900">{m.count}</p>
              <p className="text-sm font-bold text-slate-800 mt-1">{m.label}</p>
              <p className="text-xs text-slate-500 mt-0.5">{m.sub}</p>
            </div>
          </div>
        </button>
      ))}
    </div>
  );
}

function AlertsSection() {
  const alerts = [
    { title: 'Humidity Low', path: 'Storage B > Chamber 2', time: '5 min ago', current: '55%', req: '85-95%', danger: 'Estimated shelf life loss: 2 days', icon: Droplet, color: 'text-red-600', bg: 'bg-red-50', border: 'border-red-100' },
    { title: 'Temperature High', path: 'Storage C > Chamber 1', time: '10 min ago', current: '15.2°C', req: '2-6°C', danger: 'Estimated inventory at risk: ₹50,000', icon: Thermometer, color: 'text-red-600', bg: 'bg-red-50', border: 'border-red-100' },
    { title: 'Ethylene High', path: 'Storage B > Chamber 3', time: '25 min ago', current: '1.2 ppm', req: '< 1 ppm', sub: 'May cause faster ripening', icon: FlaskConical, color: 'text-amber-500', bg: 'bg-amber-50', border: 'border-amber-100' },
  ];

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-2 text-red-600">
          <AlertTriangle className="w-5 h-5 fill-current" />
          <h2 className="text-lg font-bold">Immediate Action Required</h2>
        </div>
        <button className="text-sm font-semibold text-blue-600 flex items-center hover:text-blue-700 transition">
          View All Alerts &rarr;
        </button>
      </div>

      <div className="flex gap-4 overflow-x-auto pb-2">
        {alerts.map((a, i) => (
          <div key={i} className={`min-w-[340px] flex-1 ${a.bg} border ${a.border} p-5 rounded-2xl flex flex-col justify-between`}>
            <div>
              <div className="flex justify-between items-center mb-4">
                <span className="text-xs font-semibold text-slate-700">
                  <span className="text-slate-900">{a.path.split(' > ')[0]}</span> <span className="text-red-500 mx-1">&rsaquo;</span> <span className="text-red-500">{a.path.split(' > ')[1]}</span>
                </span>
                <span className="text-xs text-slate-400">{a.time}</span>
              </div>
              <div className="flex items-start gap-4">
                <div className={`p-3 rounded-full ${a.color.replace('text-', 'bg-').replace('600', '500')} flex-shrink-0`}>
                  <a.icon className="w-6 h-6 text-white" />
                </div>
                <div>
                  <h3 className="font-bold text-slate-900 text-lg mb-1">{a.title}</h3>
                  <p className="text-xs text-slate-600 mb-2">
                    Current: <span className={a.color + " font-bold"}>{a.current}</span> <span className="ml-2">Required: {a.req}</span>
                  </p>
                  {a.danger ? (
                    <p className="text-sm font-bold text-red-600">{a.danger}</p>
                  ) : (
                    <p className="text-sm font-medium text-slate-700">{a.sub}</p>
                  )}
                </div>
              </div>
            </div>
            <button className={`mt-6 self-start px-5 py-2 rounded-full border ${a.color.replace('text-', 'border-').replace('600', '200')} ${a.color} text-sm font-bold hover:bg-white/50 transition-colors bg-white/80 shadow-sm`}>
              View Details
            </button>
          </div>
        ))}
      </div>
    </div>
  );
}

function StorageGrid({ activeFilter }) {
  const allStorages = [
    { name: 'Storage A', status: 'Healthy', chambers: 2, crops: 'Tomato, Potato', health: 95, metrics: { temp: 4.2, hum: 88, co2: 620, eth: 0.7 } },
    { name: 'Storage B', status: 'Warning', chambers: 3, crops: 'Leafy Veg, Carrot', health: 72, metrics: { temp: 3.8, hum: 55, co2: 680, eth: 1.2 } },
    { name: 'Storage C', status: 'Critical', chambers: 2, crops: 'Banana', health: 45, metrics: { temp: 15.2, hum: 90, co2: 550, eth: 0.9 } },
    { name: 'Storage D', status: 'Healthy', chambers: 1, crops: 'Onion', health: 89, metrics: { temp: 4.1, hum: 85, co2: 600, eth: 0.5 } },
  ];

  const storages = activeFilter === 'Total' ? allStorages : allStorages.filter(s => s.status === activeFilter);

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h2 className="text-lg font-bold text-slate-900">Your Cold Storages</h2>
        <button className="text-sm font-semibold text-blue-600 flex items-center hover:text-blue-700 transition">
          View All Storages &rarr;
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {storages.map((s, i) => (
          <StorageCard key={i} data={s} />
        ))}
      </div>
    </div>
  );
}

function StorageCard({ data }) {
  const [metrics, setMetrics] = useState(data.metrics);

  useEffect(() => {
    const interval = setInterval(() => {
      setMetrics(prev => ({
        temp: +(prev.temp + (Math.random() * 0.4 - 0.2)).toFixed(1),
        hum: Math.round(prev.hum + (Math.random() * 4 - 2)),
        co2: Math.round(prev.co2 + (Math.random() * 20 - 10)),
        eth: +(prev.eth + (Math.random() * 0.2 - 0.1)).toFixed(1)
      }));
    }, 5000);
    return () => clearInterval(interval);
  }, []);

  const getStatusColor = (status) => {
    switch(status) {
      case 'Healthy': return { text: 'text-emerald-600', bg: 'bg-emerald-50', border: 'border-emerald-200', bar: 'bg-emerald-500' };
      case 'Warning': return { text: 'text-amber-500', bg: 'bg-amber-50', border: 'border-amber-200', bar: 'bg-amber-400' };
      case 'Critical': return { text: 'text-red-600', bg: 'bg-red-50', border: 'border-red-200', bar: 'bg-red-500' };
      default: return { text: 'text-slate-600', bg: 'bg-slate-50', border: 'border-slate-200', bar: 'bg-slate-500' };
    }
  };

  const style = getStatusColor(data.status);

  return (
    <div className="bg-white border border-slate-200 rounded-2xl p-5 shadow-sm hover:shadow-md transition-shadow flex flex-col justify-between">
      <div>
        <div className="flex justify-between items-start mb-4">
          <div>
            <div className="flex items-center gap-2 mb-2">
              <h3 className="font-bold text-slate-900 text-lg">{data.name}</h3>
              <span className={`text-[10px] font-bold px-2 py-0.5 rounded-full border ${style.bg} ${style.border} ${style.text}`}>
                {data.status}
              </span>
            </div>
            <p className="text-xs text-slate-600 font-medium">Active &bull; {data.chambers} Chambers</p>
            <p className="text-xs text-slate-500 mt-1">{data.crops}</p>
          </div>
          <div className="p-2 bg-slate-50 rounded-lg">
            <Database className="w-8 h-8 text-slate-300" strokeWidth={1} />
          </div>
        </div>

        <div className="my-6">
          <p className="text-xs font-semibold text-slate-500 mb-2">Overall Health</p>
          <div className="flex items-center gap-3">
            <span className={`text-2xl font-bold ${style.text}`}>{data.health}%</span>
            <div className="flex-1 h-2 bg-slate-100 rounded-full overflow-hidden">
              <div className={`h-full ${style.bar} rounded-full transition-all duration-1000`} style={{ width: `${data.health}%` }} />
            </div>
          </div>
        </div>

        <div className="grid grid-cols-4 gap-2 mb-6">
          <div className="flex flex-col items-center">
            <Thermometer className="w-4 h-4 text-emerald-500 mb-1" />
            <span className="font-bold text-sm text-slate-900">{metrics.temp}&deg;C</span>
            <span className="text-[10px] text-slate-500 font-medium">Temp</span>
          </div>
          <div className="flex flex-col items-center">
            <Droplet className="w-4 h-4 text-blue-400 mb-1" />
            <span className="font-bold text-sm text-slate-900">{metrics.hum}%</span>
            <span className="text-[10px] text-slate-500 font-medium">Humidity</span>
          </div>
          <div className="flex flex-col items-center">
            <Wind className="w-4 h-4 text-emerald-500 mb-1" />
            <span className="font-bold text-sm text-slate-900">{metrics.co2}</span>
            <span className="text-[10px] text-slate-500 font-medium">CO₂ ppm</span>
          </div>
          <div className="flex flex-col items-center">
            <FlaskConical className="w-4 h-4 text-emerald-500 mb-1" />
            <span className="font-bold text-sm text-slate-900">{metrics.eth}</span>
            <span className="text-[10px] text-slate-500 font-medium">Ethylene</span>
          </div>
        </div>
      </div>
      
      <button className="w-full text-center text-sm font-bold text-blue-600 hover:text-blue-700 transition py-2">
        View Details &rarr;
      </button>
    </div>
  );
}

function QuickActions() {
  const actions = [
    { icon: PlusCircle, title: 'Add Goods', sub: 'Add new inventory', color: 'text-emerald-500', bg: 'bg-emerald-50' },
    { icon: Settings, title: 'Recommended Settings', sub: 'Apply best settings', color: 'text-blue-500', bg: 'bg-blue-50' },
    { icon: Headset, title: 'Technician Support', sub: 'Request assistance', color: 'text-purple-500', bg: 'bg-purple-50' },
    { icon: ClipboardList, title: 'Reports', sub: 'View & export', color: 'text-amber-500', bg: 'bg-amber-50' },
    { icon: Activity, title: 'Diagnostics', sub: 'Check system health', color: 'text-cyan-500', bg: 'bg-cyan-50' },
  ];

  return (
    <div className="space-y-4">
      <h2 className="text-lg font-bold text-slate-900">Quick Actions</h2>
      <div className="flex gap-4 overflow-x-auto pb-4">
        {actions.map((a, i) => (
          <button key={i} className="flex-1 min-w-[240px] bg-white border border-slate-200 p-4 rounded-2xl flex items-center gap-4 hover:border-slate-300 hover:shadow-sm transition text-left">
            <div className={`p-3 rounded-full ${a.bg}`}>
              <a.icon className={`w-6 h-6 ${a.color}`} />
            </div>
            <div>
              <h3 className="font-bold text-slate-900 text-sm">{a.title}</h3>
              <p className="text-xs text-slate-500 mt-0.5">{a.sub}</p>
            </div>
          </button>
        ))}
      </div>
    </div>
  );
}
