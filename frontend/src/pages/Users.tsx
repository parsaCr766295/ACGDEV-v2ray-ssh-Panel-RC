import React, { useState, useEffect } from 'react';
import api from '@/api/axios';
import { Users as UsersIcon, Plus, Trash2, Edit2, Shield, UserX, UserCheck } from 'lucide-react';

interface User {
  id: number;
  username: string;
  is_active: boolean;
  is_superuser: boolean;
  full_name?: string;
}

const UsersPage = () => {
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [newUser, setNewUser] = useState({ username: '', password: '', is_superuser: false });

  useEffect(() => {
    fetchUsers();
  }, []);

  const fetchUsers = async () => {
    try {
      const response = await api.get('/users/');
      setUsers(response.data);
    } catch (error) {
      console.error(error);
    } finally {
      setLoading(false);
    }
  };

  const handleAddUser = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await api.post('/users/', { ...newUser, is_active: true });
      setShowModal(false);
      fetchUsers();
      setNewUser({ username: '', password: '', is_superuser: false });
    } catch (error) {
      alert('Error adding user');
    }
  };

  return (
    <div>
      <div className="flex justify-between items-center mb-8">
        <h1 className="text-3xl font-bold text-white">مدیریت کاربران</h1>
        <button
          onClick={() => setShowModal(true)}
          className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg flex items-center gap-2"
        >
          <Plus size={20} />
          افزودن کاربر
        </button>
      </div>

      <div className="bg-gray-800 rounded-lg overflow-hidden shadow-lg border border-gray-700">
        <table className="w-full text-right">
          <thead className="bg-gray-900 text-gray-400">
            <tr>
              <th className="p-4">شناسه</th>
              <th className="p-4">نام کاربری</th>
              <th className="p-4">وضعیت</th>
              <th className="p-4">دسترسی</th>
              <th className="p-4">عملیات</th>
            </tr>
          </thead>
          <tbody className="text-gray-300 divide-y divide-gray-700">
            {users.map((user) => (
              <tr key={user.id} className="hover:bg-gray-700/50">
                <td className="p-4">#{user.id}</td>
                <td className="p-4 font-medium text-white">{user.username}</td>
                <td className="p-4">
                  <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                    user.is_active ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                  }`}>
                    {user.is_active ? 'فعال' : 'غیرفعال'}
                  </span>
                </td>
                <td className="p-4">
                  {user.is_superuser ? (
                    <span className="flex items-center gap-1 text-purple-400">
                      <Shield size={16} /> مدیر کل
                    </span>
                  ) : (
                    <span className="text-gray-400">کاربر عادی</span>
                  )}
                </td>
                <td className="p-4">
                  <div className="flex gap-2">
                    <button className="p-1 hover:text-blue-400"><Edit2 size={18} /></button>
                    {/* Add delete logic later, protecting self-deletion */}
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {showModal && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50">
          <div className="bg-gray-800 p-8 rounded-lg w-full max-w-md">
            <h2 className="text-2xl font-bold text-white mb-6">افزودن کاربر جدید</h2>
            <form onSubmit={handleAddUser} className="space-y-4">
              <input
                placeholder="نام کاربری"
                className="w-full bg-gray-700 text-white p-3 rounded"
                value={newUser.username}
                onChange={e => setNewUser({...newUser, username: e.target.value})}
                required
              />
              <input
                type="password"
                placeholder="رمز عبور"
                className="w-full bg-gray-700 text-white p-3 rounded"
                value={newUser.password}
                onChange={e => setNewUser({...newUser, password: e.target.value})}
                required
              />
              <label className="flex items-center gap-2 text-white">
                <input
                  type="checkbox"
                  checked={newUser.is_superuser}
                  onChange={e => setNewUser({...newUser, is_superuser: e.target.checked})}
                  className="rounded bg-gray-700 border-gray-600"
                />
                دسترسی مدیر کل (Superuser)
              </label>
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

export default UsersPage;
