import React, { useEffect, useState } from 'react';
import api from '@/api/axios';
import { Activity, Server, Users, Cpu, HardDrive } from 'lucide-react';

interface SystemStats {
  users: number;
  servers: number;
  active_servers: number;
  cpu_usage: number;
  memory_usage: number;
  active_connections: number;
}

const Dashboard = () => {
  const [stats, setStats] = useState<SystemStats>({
    users: 0,
    servers: 0,
    active_servers: 0,
    cpu_usage: 0,
    memory_usage: 0,
    active_connections: 0
  });

  useEffect(() => {
    fetchStats();
    // Poll stats every 10 seconds
    const interval = setInterval(fetchStats, 10000);
    return () => clearInterval(interval);
  }, []);

  const fetchStats = async () => {
    try {
      const response = await api.get('/system/stats');
      setStats(response.data);
    } catch (error) {
      console.error("Failed to fetch system stats", error);
    }
  };

  const StatCard = ({ title, value, icon: Icon, color, subtitle }: any) => (
    <div className="bg-gray-800 p-6 rounded-lg shadow-lg border border-gray-700 flex items-center">
      <div className={`p-4 rounded-full ${color} bg-opacity-20 mr-4`}>
        <Icon size={24} className={color.replace('bg-', 'text-')} />
      </div>
      <div>
        <h3 className="text-gray-400 text-sm font-medium">{title}</h3>
        <p className="text-2xl font-bold text-white">{value}</p>
        {subtitle && <p className="text-xs text-gray-500 mt-1">{subtitle}</p>}
      </div>
    </div>
  );

  return (
    <div>
      <h1 className="text-3xl font-bold text-white mb-8">داشبورد</h1>
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatCard 
          title="سرورها" 
          value={`${stats.active_servers} / ${stats.servers}`} 
          icon={Server} 
          color="bg-blue-500"
          subtitle="فعال / کل"
        />
        <StatCard 
          title="کاربران" 
          value={stats.users} 
          icon={Users} 
          color="bg-green-500" 
        />
        <StatCard 
          title="مصرف پردازنده" 
          value={`${stats.cpu_usage}%`} 
          icon={Cpu} 
          color={stats.cpu_usage > 80 ? "bg-red-500" : "bg-purple-500"}
        />
        <StatCard 
          title="مصرف رم" 
          value={`${stats.memory_usage}%`} 
          icon={HardDrive} 
          color={stats.memory_usage > 80 ? "bg-red-500" : "bg-yellow-500"}
        />
      </div>

      {/* Quick Actions or Charts could go here */}
      <div className="mt-8 grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div className="bg-gray-800 p-6 rounded-lg border border-gray-700">
              <h2 className="text-xl font-bold text-white mb-4">وضعیت سرویس‌ها</h2>
              <div className="space-y-4">
                  <div className="flex justify-between items-center">
                      <span className="text-gray-400">Database</span>
                      <span className="text-green-500 text-sm bg-green-500/10 px-2 py-1 rounded">Online</span>
                  </div>
                  <div className="flex justify-between items-center">
                      <span className="text-gray-400">Backend API</span>
                      <span className="text-green-500 text-sm bg-green-500/10 px-2 py-1 rounded">Online</span>
                  </div>
              </div>
          </div>
      </div>
    </div>
  );
};

export default Dashboard;
