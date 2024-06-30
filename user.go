package main

type User struct {
	ID    uint   `gorm:"primaryKey"`
	Name  string `gorm:"unique"`
	Value string
}

// Create a new user
func createUser(name, value string) error {
	user := User{Name: name, Value: value}
	result := db.Create(&user)
	return result.Error
}

// Retrieve a user by ID
func getUserByID(id uint) (User, error) {
	var user User
	result := db.First(&user, id)
	return user, result.Error
}

// Update a user's value
func updateUserValue(id uint, value string) error {
	var user User
	result := db.First(&user, id)
	if result.Error != nil {
		return result.Error
	}

	user.Value = value
	result = db.Save(&user)
	return result.Error
}

// Delete a user by ID
func deleteUser(id uint) error {
	result := db.Delete(&User{}, id)
	return result.Error
}
