package com.example.mediroster;

import android.content.Intent;
import android.database.Cursor;
import android.os.Bundle;
import android.view.Gravity;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Locale;

public class MyShiftsPage extends AppCompatActivity {

    private LinearLayout shiftContainer;
    private UserDatabaseHelper dbHelper;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_my_shifts);

        shiftContainer = findViewById(R.id.assigned_cases_container);
        dbHelper = new UserDatabaseHelper(this);

        Intent intent = getIntent();
        String username = intent.getStringExtra("username");

        if (username != null) {
            loadAssignedCases(username);
        } else {
            TextView errorText = new TextView(this);
            errorText.setText("No user logged in.");
            shiftContainer.addView(errorText);
        }
    }

    private void loadAssignedCases(String username) {
        String today = new SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Calendar.getInstance().getTime());

        // Title
        TextView title = new TextView(this);
        title.setText("My Shifts");
        title.setGravity(Gravity.CENTER);
        title.setTextSize(24);
        title.setPadding(0, 0, 0, 20);
        shiftContainer.addView(title);

        // Subtitle
        TextView subtitle = new TextView(this);
        subtitle.setText("Today's Assigned Cases:");
        subtitle.setTextSize(18);
        subtitle.setPadding(0, 0, 0, 16);
        shiftContainer.addView(subtitle);

        Cursor cursor = dbHelper.getAssignedCasesWithCaseTimes(username, today);
        if (cursor.getCount() == 0) {
            TextView emptyView = new TextView(this);
            emptyView.setText("You have no assigned cases today.");
            shiftContainer.addView(emptyView);
        } else {
            while (cursor.moveToNext()) {
                String desc = cursor.getString(cursor.getColumnIndexOrThrow("description"));
                String start = cursor.getString(cursor.getColumnIndexOrThrow("start_time"));
                String end = cursor.getString(cursor.getColumnIndexOrThrow("end_time"));

                TextView shiftText = new TextView(this);
                shiftText.setText("🏥 " + desc + "\n🕒 " + start + " - " + end);
                shiftText.setTextSize(16);
                shiftText.setPadding(0, 0, 0, 24);
                shiftContainer.addView(shiftText);
            }
        }
    }
}
