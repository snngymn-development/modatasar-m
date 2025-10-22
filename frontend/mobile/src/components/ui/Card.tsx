import React from 'react'
import { View, Text, StyleSheet, ViewStyle, TextStyle } from 'react-native'

interface CardProps {
  children: React.ReactNode
  style?: ViewStyle
  padding?: 'small' | 'medium' | 'large'
  shadow?: boolean
}

export function Card({ 
  children, 
  style, 
  padding = 'medium',
  shadow = true 
}: CardProps) {
  const cardStyle = [
    styles.card,
    styles[padding],
    shadow && styles.shadow,
    style
  ]

  return (
    <View style={cardStyle}>
      {children}
    </View>
  )
}

interface CardHeaderProps {
  title: string
  subtitle?: string
  style?: ViewStyle
  titleStyle?: TextStyle
  subtitleStyle?: TextStyle
}

export function CardHeader({ 
  title, 
  subtitle, 
  style, 
  titleStyle, 
  subtitleStyle 
}: CardHeaderProps) {
  return (
    <View style={[styles.header, style]}>
      <Text style={[styles.title, titleStyle]}>{title}</Text>
      {subtitle && (
        <Text style={[styles.subtitle, subtitleStyle]}>{subtitle}</Text>
      )}
    </View>
  )
}

interface CardContentProps {
  children: React.ReactNode
  style?: ViewStyle
}

export function CardContent({ children, style }: CardContentProps) {
  return (
    <View style={[styles.content, style]}>
      {children}
    </View>
  )
}

const styles = StyleSheet.create({
  card: {
    backgroundColor: '#FFFFFF',
    borderRadius: 12,
    marginVertical: 4,
  },
  small: {
    padding: 12,
  },
  medium: {
    padding: 16,
  },
  large: {
    padding: 20,
  },
  shadow: {
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 3.84,
    elevation: 5,
  },
  header: {
    marginBottom: 12,
  },
  title: {
    fontSize: 18,
    fontWeight: '600',
    color: '#000000',
  },
  subtitle: {
    fontSize: 14,
    color: '#8E8E93',
    marginTop: 4,
  },
  content: {
    flex: 1,
  },
})
