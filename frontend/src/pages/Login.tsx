import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import api from '@/api/axios';
import { useAuth } from '@/context/AuthContext';
import { Lock, User } from 'lucide-react';

const Login = () => {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const { login } = useAuth();
  const navigate = useNavigate();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    
    // Create form data
    const formData = new FormData();
    formData.append('username', username);
    formData.append('password', password);

    try {
      const response = await api.post('/login/access-token', formData, {
        headers: { 'Content-Type': 'multipart/form-data' }
      });
      login(response.data.access_token);
      navigate('/');
    } catch (err: any) {
      console.error(err);
      if (err.response) {
        // Server responded with a status code outside of 2xx
        setError(err.response.data.detail || 'نام کاربری یا رمز عبور اشتباه است');
      } else if (err.request) {
        // Request was made but no response was received
        setError('خطا در برقراری ارتباط با سرور. لطفا اتصال اینترنت خود را بررسی کنید.');
      } else {
        // Something happened in setting up the request
        setError('خطای ناشناخته رخ داد.');
      }
    }
  };

  return (
    <div className="min-h-screen bg-gray-900 flex items-center justify-center p-4">
      <div className="bg-gray-800 p-8 rounded-lg shadow-2xl w-full max-w-md border border-gray-700">
        <h2 className="text-3xl font-bold text-center text-white mb-8">Rocket Panel 2026</h2>
        {error && (
            <div className="bg-red-500/10 border border-red-500 text-red-500 px-4 py-2 rounded mb-4 text-center">
                {error}
            </div>
        )}
        <form onSubmit={handleSubmit} className="space-y-6">
          <div className="relative">
            <User className="absolute right-3 top-3 text-gray-400" size={20} />
            <input
              type="text"
              placeholder="نام کاربری"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              className="w-full bg-gray-700 text-white border border-gray-600 rounded-lg py-2 px-4 pr-10 focus:outline-none focus:border-blue-500"
              required
            />
          </div>
          <div className="relative">
            <Lock className="absolute right-3 top-3 text-gray-400" size={20} />
            <input
              type="password"
              placeholder="رمز عبور"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="w-full bg-gray-700 text-white border border-gray-600 rounded-lg py-2 px-4 pr-10 focus:outline-none focus:border-blue-500"
              required
            />
          </div>
          <button
            type="submit"
            className="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded-lg transition duration-200"
          >
            ورود به پنل
          </button>
        </form>
      </div>
    </div>
  );
};

export default Login;
