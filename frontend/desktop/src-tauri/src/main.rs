// Prevents additional console window on Windows in release
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

use serde::{Deserialize, Serialize};
use std::collections::HashMap;

#[derive(Debug, Serialize, Deserialize)]
struct Customer {
    id: String,
    name: String,
    phone: String,
    email: String,
    city: String,
    stars: u32,
    status: String,
    created_at: String,
}

#[derive(Debug, Serialize, Deserialize)]
struct CustomerData {
    customers: HashMap<String, Customer>,
}

impl Default for CustomerData {
    fn default() -> Self {
        let mut customers = HashMap::new();
        
        // Add some sample customers
        customers.insert("1".to_string(), Customer {
            id: "1".to_string(),
            name: "Ahmet Yılmaz".to_string(),
            phone: "+90 532 123 45 67".to_string(),
            email: "ahmet@example.com".to_string(),
            city: "İstanbul".to_string(),
            stars: 5,
            status: "ACTIVE".to_string(),
            created_at: chrono::Utc::now().to_rfc3339(),
        });
        
        customers.insert("2".to_string(), Customer {
            id: "2".to_string(),
            name: "Ayşe Demir".to_string(),
            phone: "+90 533 987 65 43".to_string(),
            email: "ayse@example.com".to_string(),
            city: "Ankara".to_string(),
            stars: 4,
            status: "ACTIVE".to_string(),
            created_at: chrono::Utc::now().to_rfc3339(),
        });
        
        Self { customers }
    }
}

// Tauri commands
#[tauri::command]
fn get_customers() -> Result<Vec<Customer>, String> {
    let data = CustomerData::default();
    Ok(data.customers.values().cloned().collect())
}

#[tauri::command]
fn add_customer(name: String, phone: String, email: String, city: String) -> Result<Customer, String> {
    let id = chrono::Utc::now().timestamp().to_string();
    let customer = Customer {
        id: id.clone(),
        name,
        phone,
        email,
        city,
        stars: 0,
        status: "ACTIVE".to_string(),
        created_at: chrono::Utc::now().to_rfc3339(),
    };
    Ok(customer)
}

#[tauri::command]
fn update_customer_stars(id: String, stars: u32) -> Result<(), String> {
    // In a real app, this would update the database
    println!("Updating customer {} stars to {}", id, stars);
    Ok(())
}

#[tauri::command]
fn delete_customer(id: String) -> Result<(), String> {
    // In a real app, this would delete from database
    println!("Deleting customer {}", id);
    Ok(())
}

#[tauri::command]
fn export_customers_csv() -> Result<String, String> {
    let data = CustomerData::default();
    let mut csv = String::from("ID,Ad,Telefon,E-posta,Şehir,Yıldız,Durum,Kayıt Tarihi\n");
    
    for customer in data.customers.values() {
        csv.push_str(&format!(
            "{},{},{},{},{},{},{},{}\n",
            customer.id, customer.name, customer.phone, 
            customer.email, customer.city, customer.stars, 
            customer.status, customer.created_at
        ));
    }
    
    Ok(csv)
}

#[tauri::command]
fn get_system_info() -> Result<HashMap<String, String>, String> {
    let mut info = HashMap::new();
    info.insert("os".to_string(), std::env::consts::OS.to_string());
    info.insert("arch".to_string(), std::env::consts::ARCH.to_string());
    info.insert("version".to_string(), env!("CARGO_PKG_VERSION").to_string());
    Ok(info)
}

fn main() {
    tauri::Builder::default()
        .invoke_handler(tauri::generate_handler![
            get_customers,
            add_customer,
            update_customer_stars,
            delete_customer,
            export_customers_csv,
            get_system_info
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}

