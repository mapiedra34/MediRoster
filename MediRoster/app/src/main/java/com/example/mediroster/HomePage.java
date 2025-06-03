package com.example.mediroster;

import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup.LayoutParams;
import android.widget.GridLayout;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;
import androidx.cardview.widget.CardView;

import java.util.Calendar;

public class HomePage extends AppCompatActivity {

    private GridLayout homeGrid;
    private String role, username;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_home);

        homeGrid = findViewById(R.id.home_grid);
        TextView greetingText = findViewById(R.id.greeting_text); // new greeting view

        Intent intent = getIntent();
        username = intent.getStringExtra("username");
        role = intent.getStringExtra("role");

        // Gets display name from database
        UserDatabaseHelper dbHelper = new UserDatabaseHelper(this);
        String displayName = dbHelper.getDisplayName(username);

        // Gets time of day
        int hour = Calendar.getInstance().get(Calendar.HOUR_OF_DAY);
        String greeting;
        if (hour < 12) {
            greeting = "Good morning, " + displayName + "!";
        } else if (hour < 17) {
            greeting = "Good afternoon, " + displayName + "!";
        } else {
            greeting = "Good evening, " + displayName + "!";
        }
        TextView adminFooter = findViewById(R.id.admin_footer);
        greetingText.setText(greeting); //update greeting message

        // Admin/Nurse tiles
        if ("admin".equalsIgnoreCase(role)) {
            addTile("Add Case", AddCasePage.class);
            addTile("Edit Case", EditCasePage.class);
            addTile("Manage Shifts", AddEditShiftPage.class);
            addTile("Check-In Nurses", CheckInPage.class);
            addTile("View Today's Cases", ViewCasesPage.class);

            adminFooter.setVisibility(View.VISIBLE);
        } else if ("nurse".equalsIgnoreCase(role)) {
            addTile("My Shifts", MyShiftsPage.class);
        }

        addTile("Logout", LoginPage.class, true);
    }


    private void addTile(String label, Class<?> targetActivity) {
        addTile(label, targetActivity, false);
    }

    private void addTile(String label, Class<?> targetActivity, boolean isLogout) {
        CardView card = new CardView(this);
        card.setRadius(20);
        card.setCardElevation(8);
        card.setUseCompatPadding(true);
        card.setCardBackgroundColor(Color.parseColor("#BBDEFB")); // light blue
        GridLayout.LayoutParams params = new GridLayout.LayoutParams();
        params.width = 0;
        params.height = LayoutParams.WRAP_CONTENT;
        params.columnSpec = GridLayout.spec(GridLayout.UNDEFINED, 1f);
        params.setMargins(16, 16, 16, 16);
        card.setLayoutParams(params);

        TextView text = new TextView(this);
        text.setText(label);
        text.setTextSize(18f);
        text.setGravity(Gravity.CENTER);
        text.setTextColor(Color.BLACK);
        text.setPadding(32, 48, 32, 48);

        card.addView(text);
        card.setOnClickListener(v -> {
            Intent intent = new Intent(HomePage.this, targetActivity);
            if (!isLogout) {
                intent.putExtra("username", username);
                intent.putExtra("role", role);
                startActivity(intent);
            } else {
                intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
                startActivity(intent);
                finish();
            }
        });

        homeGrid.addView(card);
    }
}
