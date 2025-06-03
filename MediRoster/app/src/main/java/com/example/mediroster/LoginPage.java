package com.example.mediroster;

import android.content.Intent;
import android.os.Bundle;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

public class LoginPage extends AppCompatActivity {

    private EditText usernameInput, passwordInput;
    private Button loginBtn;
    private UserDatabaseHelper dbHelper;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.login_page); // Custom login layout

        // Initialize views
        usernameInput = findViewById(R.id.username_input);
        passwordInput = findViewById(R.id.password_input);
        loginBtn = findViewById(R.id.login_btn);

        // Initialize database helper
        dbHelper = new UserDatabaseHelper(this);

        // login button
        loginBtn.setOnClickListener(v -> {
            String username = usernameInput.getText().toString().trim();
            String password = passwordInput.getText().toString().trim();

            if (username.isEmpty() || password.isEmpty()) {
                Toast.makeText(LoginPage.this, "Please enter all fields", Toast.LENGTH_SHORT).show();
                return;
            }

            // Check login credentials
            if (validateLogin(username, password)) {
                Toast.makeText(LoginPage.this, "Login successful!", Toast.LENGTH_SHORT).show();
                // Navigate to next activity or screen
                Intent intent = new Intent(LoginPage.this, HomePage.class);
                intent.putExtra("username", username);
                String role = dbHelper.getUserRole(username, password);
                intent.putExtra("role", role);
                startActivity(intent);
                finish();

            } else {
                Toast.makeText(LoginPage.this, "Invalid username or password", Toast.LENGTH_SHORT).show();
            }
        });

        // Register link listener
       /* TextView registerLink = findViewById(R.id.register_link);
        registerLink.setOnClickListener(v -> {
            Intent intent = new Intent(LoginPage.this, RegisterPage.class);
            startActivity(intent);
        });*/
        //removed registration link
    }


        // Validate user login credentials
        private boolean validateLogin (String username, String password){
            return dbHelper.validateLogin(username, password);
        }

    }

