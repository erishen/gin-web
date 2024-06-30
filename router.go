package main

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

func setupRouter() *gin.Engine {
	r := gin.Default()

	r.GET("/ping", func(c *gin.Context) {
		c.String(http.StatusOK, "pong")
	})

	// Create user
	r.POST("/user", func(c *gin.Context) {
		var json struct {
			Name  string `json:"name" binding:"required"`
			Value string `json:"value" binding:"required"`
		}

		if err := c.BindJSON(&json); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}

		if err := createUser(json.Name, json.Value); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create user"})
			return
		}

		c.JSON(http.StatusOK, gin.H{"status": "ok"})
	})

	// Get user by ID
	r.GET("/user/:id", func(c *gin.Context) {
		id := c.Param("id")
		userId, err := strconv.ParseUint(id, 10, 64)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
			return
		}

		user, err := getUserByID(uint(userId))
		if err != nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
			return
		}

		c.JSON(http.StatusOK, gin.H{"user": user})
	})

	// Update user value by ID
	r.PUT("/user/:id", func(c *gin.Context) {
		id := c.Param("id")
		userId, err := strconv.ParseUint(id, 10, 64)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
			return
		}

		var json struct {
			Value string `json:"value" binding:"required"`
		}

		if err := c.BindJSON(&json); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}

		if err := updateUserValue(uint(userId), json.Value); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update user"})
			return
		}

		c.JSON(http.StatusOK, gin.H{"status": "ok"})
	})

	// Delete user by ID
	r.DELETE("/user/:id", func(c *gin.Context) {
		id := c.Param("id")
		userId, err := strconv.ParseUint(id, 10, 64)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
			return
		}

		if err := deleteUser(uint(userId)); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete user"})
			return
		}

		c.JSON(http.StatusOK, gin.H{"status": "ok"})
	})

	return r
}
