import React, { useState, useEffect } from 'react';
import api from '@/api/axios';
import { Server, Plus, Trash2, Terminal } from 'lucide-react';

interface ServerData {
  id: number;
  name: string;
  host: string;
  username: string;
  is_active: boolean;
}

const Servers = () => {
  const [servers, setServers] = useState<ServerData[]>([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [newServer, setNewServer] = useState({ name: '', host: '', username: '', password: '', port: 22 });

  useEffect(() => {
    fetchServers();
  }, []);

  const fetchServers = async () => {
    try {
      const response = await api.get('/servers/');
      setServers(response.data);
    } catch (error) {
      console.error(error);
    } finally {
      setLoading(false);
    }
  };

  const handleAddServer = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await api.post('/servers/', newServer);
      setShowModal(false);
      fetchServers();
      setNewServer({ name: '', host: '', username: '', password: '', port: 22 });
    } catch (error) {
      alert('Error adding server');
    }
  };
  
  const handleDelete = async (id: number) => {
      if(!confirm('Are you sure?')) return;
      try {
          await api.delete(`/servers/${id}`);
          fetchServers();
      } catch (error) {
          console.error(error);
      }
  }

  return (
    <div>
      <div className="flex justify-between items-center mb-8">
        <h1 className="text-3xl font-bold text-white">مدیریت سرورها</h1>
        <button
          onClick={() => setShowModal(true)}
          className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg flex items-center gap-2"
        >
          <Plus size={20} />
          افزودن سرور
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {servers.map((server) => (
          <div key={server.id} className="bg-gray-800 p-6 rounded-lg border border-gray-700 shadow-lg">
            <div className="flex justify-between items-start mb-4">
              <div className="p-3 bg-blue-500/20 rounded-lg">
                <Server className="text-blue-500" size={24} />
              </div>
              <div className={`px-2 py-1 rounded text-xs ${server.is_active ? 'bg-green-500/20 text-green-500' : 'bg-red-500/20 text-red-500'}`}>
                {server.is_active ? 'Active' : 'Inactive'}
              </div>
            </div>
            <h3 className="text-xl font-bold text-white mb-2">{server.name}</h3>
            <p className="text-gray-400 text-sm mb-4">{server.username}@{server.host}</p>
            <div className="flex gap-2 mt-4">
                <button className="flex-1 bg-gray-700 hover:bg-gray-600 text-white py-2 rounded flex justify-center items-center gap-2">
                    <Terminal size={16} />
                    Terminal
                </button>
                <button onClick={() => handleDelete(server.id)} className="p-2 bg-red-500/10 text-red-500 hover:bg-red-500/20 rounded">
                    <Trash2 size={20} />
                </button>
            </div>
          </div>
        ))}
      </div>

      {showModal && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50">
          <div className="bg-gray-800 p-8 rounded-lg w-full max-w-md">
            <h2 className="text-2xl font-bold text-white mb-6">افزودن سرور جدید</h2>
            <form onSubmit={handleAddServer} className="space-y-4">
              <input
                placeholder="نام سرور"
                className="w-full bg-gray-700 text-white p-3 rounded"
                value={newServer.name}
                onChange={e => setNewServer({...newServer, name: e.target.value})}
                required
              />
              <input
                placeholder="آدرس IP / Host"
                className="w-full bg-gray-700 text-white p-3 rounded"
                value={newServer.host}
                onChange={e => setNewServer({...newServer, host: e.target.value})}
                required
              />
              <input
                placeholder="نام کاربری (root)"
                className="w-full bg-gray-700 text-white p-3 rounded"
                value={newServer.username}
                onChange={e => setNewServer({...newServer, username: e.target.value})}
                required
              />
              <input
                type="password"
                placeholder="رمز عبور"
                className="w-full bg-gray-700 text-white p-3 rounded"
                value={newServer.password}
                onChange={e => setNewServer({...newServer, password: e.target.value})}
              />
              <div className="flex gap-4 mt-6">
                <button type="button" onClick={() => setShowModal(false)} className="flex-1 bg-gray-600 text-white py-2 rounded">انصراف</button>
                <button type="submit" className="flex-1 bg-blue-600 text-white py-2 rounded">ذخیره</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default Servers;
