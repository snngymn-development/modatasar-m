import React from 'react'
import { View, Text, StyleSheet, ScrollView } from 'react-native'

export default function ScheduleScreen() {
  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>📅 Takvim</Text>
      </View>
      <View style={styles.content}>
        <Text style={styles.text}>Randevu ve takvim yönetimi</Text>
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
    color: '#374151'
  }
})

