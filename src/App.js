import React, { Suspense, lazy } from 'react';
import { Routes, Route } from 'react-router-dom';
import { UserProvider } from './context/UserContext';
import { ThemeProvider } from './context/ThemeContext';
import { RoomReservationProvider } from './context/RoomReservationContext';
import { ModalProvider } from './context/ModalContext';
import { GuestProvider } from './context/GuestContext';
import { RoomProvider } from './context/RoomContext';
import { ReservationProvider } from './context/ReservationContext';
import Home from './pages/Home';
import RoomsPage from './components/RoomsPage';
import ReservationsPage from './components/ReservationsPage';
import ProfileModal from './components/ProfileModal';
import SettingsPage from './components/SettingsPage';
import { Toaster } from 'react-hot-toast';
import ProtectedRoute from './components/ProtectedRoute';

// Use lazy loading for route components
const LandingPage = lazy(() => import('./components/LandingPage'));
const Dashboard = lazy(() => import('./components/Dashboard'));
const GuestsPage = lazy(() => import('./components/GuestsPage'));
const TasksPage = lazy(() => import('./components/TasksPage'));
const BillingPage = lazy(() => import('./components/BillingPage'));
const ServicesPage = lazy(() => import('./components/ServicesPage'));
const AdminAccessControl = lazy(() => import('./components/AdminAccessControl'));
const ManagerAccessControl = lazy(() => import('./components/ManagerAccessControl'));
const TestAccessRequests = lazy(() => import('./pages/TestAccessRequests'));
const ReportsPage = lazy(() => import('./components/Reports'));
const RequestAccessPage = lazy(() => import('./pages/RequestAccessPage'));
const LoginPage = lazy(() => import('./pages/LoginPage'));

// Loading component for Suspense
const LoadingFallback = () => (
  <div className="flex items-center justify-center min-h-screen p-5 bg-gray-100 min-w-screen">
    <div className="flex space-x-2 animate-pulse">
      <div className="w-3 h-3 bg-blue-500 rounded-full"></div>
      <div className="w-3 h-3 bg-blue-500 rounded-full"></div>
      <div className="w-3 h-3 bg-blue-500 rounded-full"></div>
    </div>
  </div>
);

// Simple NotFound component for 404 routes
const NotFound = () => (
  <div className="flex flex-col items-center justify-center min-h-screen p-5 bg-gray-100 min-w-screen dark:bg-gray-900 dark:text-white">
    <h1 className="text-4xl font-bold mb-4">404 - Page Not Found</h1>
    <p className="text-xl mb-6">The page you are looking for doesn't exist or has been moved.</p>
    <a href="/" className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 transition-colors">
      Go Home
    </a>
    <div className="mt-8 text-gray-500 dark:text-gray-400">
      <p>If you believe this is an error, please contact the system administrator.</p>
      <p className="mt-2">You can also try clearing your browser cache and cookies.</p>
    </div>
  </div>
);

const App = () => {
  return (
    <ThemeProvider>
      <UserProvider>
        <RoomReservationProvider>
          <RoomProvider>
            <ReservationProvider>
              <ModalProvider>
                <GuestProvider>
                  <Suspense fallback={<LoadingFallback />}>
                    <Routes>
                      <Route path="/" element={<Home />} />
                      <Route path="/landing" element={<LandingPage />} />
                      <Route path="/login" element={<LoginPage />} />
                      <Route path="/request-access" element={<RequestAccessPage />} />
                      
                      {/* Protected Routes */}
                      <Route path="/dashboard" element={
                        <ProtectedRoute>
                          <Dashboard />
                        </ProtectedRoute>
                      } />
                      <Route path="/rooms" element={
                        <ProtectedRoute>
                          <RoomsPage />
                        </ProtectedRoute>
                      } />
                      <Route path="/reservations" element={
                        <ProtectedRoute>
                          <ReservationsPage />
                        </ProtectedRoute>
                      } />
                      <Route path="/guests" element={
                        <ProtectedRoute>
                          <GuestsPage />
                        </ProtectedRoute>
                      } />
                      <Route path="/tasks" element={
                        <ProtectedRoute>
                          <TasksPage />
                        </ProtectedRoute>
                      } />
                      <Route path="/billing" element={
                        <ProtectedRoute>
                          <BillingPage />
                        </ProtectedRoute>
                      } />
                      <Route path="/services" element={
                        <ProtectedRoute>
                          <ServicesPage />
                        </ProtectedRoute>
                      } />
                      <Route path="/reports" element={
                        <ProtectedRoute>
                          <ReportsPage />
                        </ProtectedRoute>
                      } />
                      <Route path="/profile" element={
                        <ProtectedRoute>
                          <ProfileModal />
                        </ProtectedRoute>
                      } />
                      <Route path="/settings" element={
                        <ProtectedRoute>
                          <SettingsPage />
                        </ProtectedRoute>
                      } />
                      <Route path="/admin/access-control" element={
                        <ProtectedRoute>
                          <AdminAccessControl />
                        </ProtectedRoute>
                      } />
                      <Route path="/manager/access-control" element={
                        <ProtectedRoute>
                          <ManagerAccessControl />
                        </ProtectedRoute>
                      } />
                      <Route path="/test-access-requests" element={
                        <ProtectedRoute>
                          <TestAccessRequests />
                        </ProtectedRoute>
                      } />
                      
                      <Route path="*" element={<NotFound />} />
                    </Routes>
                  </Suspense>
                  <Toaster position="top-right" toastOptions={{
                    style: {
                      background: '#333',
                      color: '#fff',
                    },
                    success: {
                      duration: 3000,
                    },
                    error: {
                      duration: 5000,
                    }
                  }} />
                </GuestProvider>
              </ModalProvider>
            </ReservationProvider>
          </RoomProvider>
        </RoomReservationProvider>
      </UserProvider>
    </ThemeProvider>
  );
};

export default App;
