import React from 'react';
import { useAuth } from '@/context/AuthContext';
import { Navigate, Outlet, Link, useLocation } from 'react-router-dom';
import { LayoutDashboard, Server, Users, LogOut, Menu, X } from 'lucide-react';

const Layout = () => {
  const { user, logout } = useAuth();
  const location = useLocation();
  const [sidebarOpen, setSidebarOpen] = React.useState(false);

  if (!user) {
    return <Navigate to="/login" replace />;
  }

  const navItems = [
    { path: '/', label: 'داشبورد', icon: LayoutDashboard },
    { path: '/servers', label: 'مدیریت سرورها', icon: Server },
    { path: '/users', label: 'مدیریت کاربران', icon: Users },
  ];

  return (
    <div className="min-h-screen bg-gray-900 text-white flex">
      {/* Mobile Sidebar Overlay */}
      {sidebarOpen && (
        <div 
            className="fixed inset-0 bg-black/50 z-20 lg:hidden"
            onClick={() => setSidebarOpen(false)}
        />
      )}

      {/* Sidebar */}
      <aside className={`
        fixed lg:static inset-y-0 right-0 w-64 bg-gray-800 border-l border-gray-700 transform transition-transform duration-200 z-30
        ${sidebarOpen ? 'translate-x-0' : 'translate-x-full lg:translate-x-0'}
      `}>
        <div className="p-6 border-b border-gray-700 flex justify-between items-center">
          <h1 className="text-xl font-bold text-blue-500">Rocket Panel</h1>
          <button className="lg:hidden" onClick={() => setSidebarOpen(false)}>
            <X size={20} />
          </button>
        </div>
        <nav className="p-4 space-y-2">
          {navItems.map((item) => (
            <Link
              key={item.path}
              to={item.path}
              onClick={() => setSidebarOpen(false)}
              className={`flex items-center space-x-3 space-x-reverse px-4 py-3 rounded-lg transition-colors ${
                location.pathname === item.path
                  ? 'bg-blue-600 text-white'
                  : 'text-gray-400 hover:bg-gray-700 hover:text-white'
              }`}
            >
              <item.icon size={20} />
              <span>{item.label}</span>
            </Link>
          ))}
          <button
            onClick={logout}
            className="w-full flex items-center space-x-3 space-x-reverse px-4 py-3 rounded-lg text-red-400 hover:bg-red-500/10 hover:text-red-500 transition-colors mt-8"
          >
            <LogOut size={20} />
            <span>خروج</span>
          </button>
        </nav>
      </aside>

      {/* Main Content */}
      <main className="flex-1 flex flex-col min-w-0 overflow-hidden">
        <header className="bg-gray-800 border-b border-gray-700 p-4 lg:hidden">
            <button onClick={() => setSidebarOpen(true)} className="text-white">
                <Menu size={24} />
            </button>
        </header>
        <div className="flex-1 overflow-auto p-4 lg:p-8">
            <Outlet />
        </div>
      </main>
    </div>
  );
};

export default Layout;
