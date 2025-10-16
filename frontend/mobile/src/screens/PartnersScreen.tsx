import React from 'react'
import { View, Text, StyleSheet, ScrollView } from 'react-native'
import { TEXT } from '@shared'

export default function PartnersScreen() {
  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>👥 Müşteri & Tedarikçi</Text>
      </View>
      <View style={styles.content}>
        <Text style={styles.text}>{TEXT.tr.table?.customer || 'Müşteriler'}</Text>
        <Text style={styles.subtitle}>Müşteri ve tedarikçi yönetimi</Text>
      </View>
    </ScrollView>
  )
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f9fafb'
  },
  header: {
    padding: 20,
    backgroundColor: '#fff',
    borderBottomWidth: 1,
    borderBottomColor: '#e5e7eb'
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#111827'
  },
  content: {
    padding: 20
  },
  text: {
    fontSize: 18,
    color: '#374151',
    marginBottom: 10
  },
  subtitle: {
    fontSize: 14,
    color: '#6b7280'
  }
})

