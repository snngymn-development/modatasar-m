import React from 'react'
import { FlatList, TouchableOpacity, Text, StyleSheet, ViewStyle, TextStyle } from 'react-native'

interface ListItemProps {
  title: string
  subtitle?: string
  rightElement?: React.ReactNode
  onPress?: () => void
  style?: ViewStyle
  titleStyle?: TextStyle
  subtitleStyle?: TextStyle
}

export function ListItem({
  title,
  subtitle,
  rightElement,
  onPress,
  style,
  titleStyle,
  subtitleStyle
}: ListItemProps) {
  return (
    <TouchableOpacity
      style={[styles.item, style]}
      onPress={onPress}
      activeOpacity={0.7}
    >
      <View style={styles.content}>
        <Text style={[styles.title, titleStyle]}>{title}</Text>
        {subtitle && (
          <Text style={[styles.subtitle, subtitleStyle]}>{subtitle}</Text>
        )}
      </View>
      {rightElement && (
        <View style={styles.right}>
          {rightElement}
        </View>
      )}
    </TouchableOpacity>
  )
}

interface ListProps {
  data: any[]
  renderItem: ({ item, index }: { item: any; index: number }) => React.ReactElement
  keyExtractor: (item: any, index: number) => string
  style?: ViewStyle
  contentContainerStyle?: ViewStyle
  ItemSeparatorComponent?: React.ComponentType
}

export function List({
  data,
  renderItem,
  keyExtractor,
  style,
  contentContainerStyle,
  ItemSeparatorComponent
}: ListProps) {
  return (
    <FlatList
      data={data}
      renderItem={renderItem}
      keyExtractor={keyExtractor}
      style={style}
      contentContainerStyle={contentContainerStyle}
      ItemSeparatorComponent={ItemSeparatorComponent}
      showsVerticalScrollIndicator={false}
    />
  )
}

const styles = StyleSheet.create({
  item: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 12,
    paddingHorizontal: 16,
    backgroundColor: '#FFFFFF',
  },
  content: {
    flex: 1,
  },
  title: {
    fontSize: 16,
    fontWeight: '500',
    color: '#000000',
  },
  subtitle: {
    fontSize: 14,
    color: '#8E8E93',
    marginTop: 2,
  },
  right: {
    marginLeft: 12,
  },
})
