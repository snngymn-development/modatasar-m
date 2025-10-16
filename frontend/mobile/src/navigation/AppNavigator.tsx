import React from 'react'
import { NavigationContainer } from '@react-navigation/native'
import { createNativeStackNavigator } from '@react-navigation/native-stack'
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs'
import { RootStackParamList, BottomTabParamList } from './types'

// Import screens (will create them next)
import DashboardScreen from '../screens/DashboardScreen'
import PartnersScreen from '../screens/PartnersScreen'
import RentSaleScreen from '../screens/RentSaleScreen'
import InventoryScreen from '../screens/InventoryScreen'
import ScheduleScreen from '../screens/ScheduleScreen'
import MoreScreen from '../screens/MoreScreen'

const Stack = createNativeStackNavigator<RootStackParamList>()
const Tab = createBottomTabNavigator<BottomTabParamList>()

function BottomTabNavigator() {
  return (
    <Tab.Navigator
      screenOptions={{
        headerShown: false,
        tabBarActiveTintColor: '#3b82f6',
        tabBarInactiveTintColor: '#9ca3af'
      }}
    >
      <Tab.Screen 
        name="DashboardTab" 
        component={DashboardScreen}
        options={{ title: '🏠 Dashboard' }}
      />
      <Tab.Screen 
        name="PartnersTab" 
        component={PartnersScreen}
        options={{ title: '👥 Müşteri' }}
      />
      <Tab.Screen 
        name="RentSaleTab" 
        component={RentSaleScreen}
        options={{ title: '💳 Satış' }}
      />
      <Tab.Screen 
        name="InventoryTab" 
        component={InventoryScreen}
        options={{ title: '📦 Stok' }}
      />
      <Tab.Screen 
        name="ScheduleTab" 
        component={ScheduleScreen}
        options={{ title: '📅 Takvim' }}
      />
      <Tab.Screen 
        name="MoreTab" 
        component={MoreScreen}
        options={{ title: '⋯ Diğer' }}
      />
    </Tab.Navigator>
  )
}

export default function AppNavigator() {
  return (
    <NavigationContainer>
      <Stack.Navigator 
        initialRouteName="Dashboard"
        screenOptions={{
          headerShown: true,
          headerStyle: { backgroundColor: '#3b82f6' },
          headerTintColor: '#fff',
          headerTitleStyle: { fontWeight: 'bold' }
        }}
      >
        <Stack.Screen 
          name="Dashboard" 
          component={BottomTabNavigator}
          options={{ headerShown: false }}
        />
      </Stack.Navigator>
    </NavigationContainer>
  )
}

