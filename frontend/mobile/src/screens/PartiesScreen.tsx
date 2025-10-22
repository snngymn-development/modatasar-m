import React, { useState } from 'react'
import { View, Text, StyleSheet, ScrollView, TouchableOpacity } from 'react-native'
import { Card, CardHeader, CardContent } from '../components/ui/Card'
import { Button } from '../components/ui/Button'
import { List, ListItem } from '../components/ui/List'
import { useCustomers } from '../hooks/useCustomers'
import { Customer } from '@deneme1/shared'

export default function PartiesScreen() {
  const [activeTab, setActiveTab] = useState<'customers' | 'suppliers'>('customers')
  const { customers, loading, error } = useCustomers()

  const renderCustomerItem = ({ item }: { item: Customer }) => (
    <ListItem
      title={item.name}
      subtitle={`${item.phone} • ${item.city}`}
      rightElement={
        <View style={styles.starsContainer}>
          <Text style={styles.stars}>{'★'.repeat(item.stars)}</Text>
        </View>
      }
      onPress={() => {
        // Navigate to customer detail
        console.log('Customer selected:', item.id)
      }}
    />
  )

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>🏢 Taraflar</Text>
        <View style={styles.tabContainer}>
          <TouchableOpacity
            style={[styles.tab, activeTab === 'customers' && styles.activeTab]}
            onPress={() => setActiveTab('customers')}
          >
            <Text style={[styles.tabText, activeTab === 'customers' && styles.activeTabText]}>
              Müşteriler
            </Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={[styles.tab, activeTab === 'suppliers' && styles.activeTab]}
            onPress={() => setActiveTab('suppliers')}
          >
            <Text style={[styles.tabText, activeTab === 'suppliers' && styles.activeTabText]}>
              Tedarikçiler
            </Text>
          </TouchableOpacity>
        </View>
      </View>

      <ScrollView style={styles.content}>
        {activeTab === 'customers' && (
          <Card>
            <CardHeader title="Müşteriler" subtitle={`${customers.length} müşteri`} />
            <CardContent>
              <Button
                title="+ Yeni Müşteri"
                onPress={() => {
                  // Navigate to add customer
                  console.log('Add new customer')
                }}
                style={styles.addButton}
              />
              {loading ? (
                <Text style={styles.loadingText}>Yükleniyor...</Text>
              ) : error ? (
                <Text style={styles.errorText}>{error}</Text>
              ) : (
                <List
                  data={customers}
                  renderItem={renderCustomerItem}
                  keyExtractor={(item) => item.id}
                />
              )}
            </CardContent>
          </Card>
        )}

        {activeTab === 'suppliers' && (
          <Card>
            <CardHeader title="Tedarikçiler" subtitle="Tedarikçi listesi" />
            <CardContent>
              <Button
                title="+ Yeni Tedarikçi"
                onPress={() => {
                  // Navigate to add supplier
                  console.log('Add new supplier')
                }}
                style={styles.addButton}
              />
              <Text style={styles.comingSoonText}>Yakında...</Text>
            </CardContent>
          </Card>
        )}
      </ScrollView>
    </View>
  )
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F2F2F7',
  },
  header: {
    backgroundColor: '#FFFFFF',
    paddingTop: 50,
    paddingBottom: 16,
    paddingHorizontal: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#E5E5EA',
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#000000',
    marginBottom: 16,
  },
  tabContainer: {
    flexDirection: 'row',
    backgroundColor: '#F2F2F7',
    borderRadius: 8,
    padding: 4,
  },
  tab: {
    flex: 1,
    paddingVertical: 8,
    paddingHorizontal: 16,
    borderRadius: 6,
    alignItems: 'center',
  },
  activeTab: {
    backgroundColor: '#FFFFFF',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 2,
    elevation: 2,
  },
  tabText: {
    fontSize: 16,
    fontWeight: '500',
    color: '#8E8E93',
  },
  activeTabText: {
    color: '#007AFF',
  },
  content: {
    flex: 1,
    padding: 16,
  },
  addButton: {
    marginBottom: 16,
  },
  loadingText: {
    textAlign: 'center',
    fontSize: 16,
    color: '#8E8E93',
    marginVertical: 20,
  },
  errorText: {
    textAlign: 'center',
    fontSize: 16,
    color: '#FF3B30',
    marginVertical: 20,
  },
  comingSoonText: {
    textAlign: 'center',
    fontSize: 16,
    color: '#8E8E93',
    marginVertical: 40,
  },
  starsContainer: {
    alignItems: 'center',
  },
  stars: {
    fontSize: 16,
    color: '#FFD700',
  },
})

