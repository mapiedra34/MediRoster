package com.example.mediroster;

import android.content.Intent;
import android.database.Cursor;
import android.os.Bundle;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Locale;

public class ViewCasesPage extends AppCompatActivity {

    private ListView caseListView;
    private UserDatabaseHelper dbHelper;

    private ArrayList<String> caseLabels = new ArrayList<>();
    private HashMap<String, Integer> caseMap = new HashMap<>();

    private String role, username;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_view_cases);

        dbHelper = new UserDatabaseHelper(this);
        caseListView = findViewById(R.id.case_list_view);

        //  First get intent extras
        Intent intent = getIntent();
        role = intent.getStringExtra("role");
        username = intent.getStringExtra("username");

        //  Handle missing values early
        if (username == null || role == null) {
            Toast.makeText(this, "User info missing. Please log in again.", Toast.LENGTH_LONG).show();
            finish();
            return;
        }

        //  Then load cases
        loadTodaysCases();

        caseListView.setOnItemClickListener((parent, view, position, id) -> {
            String selectedLabel = caseLabels.get(position);
            Integer caseId = caseMap.get(selectedLabel);
            if (caseId != null) {
                Intent detailIntent = new Intent(ViewCasesPage.this, ViewCaseDetailsPage.class);
                detailIntent.putExtra("case_id", caseId);
                startActivity(detailIntent);
            } else {
                Toast.makeText(this, "Could not load case details.", Toast.LENGTH_SHORT).show();
            }
        });
    }


    private void loadTodaysCases() {
        String today = new SimpleDateFormat("yyyy-MM-dd", Locale.US).format(new Date());

        Cursor cursor;
        if ("admin".equalsIgnoreCase(role)) {
            cursor = dbHelper.getCasesForDate(today);
        } else {
            cursor = dbHelper.getCasesForUserOnDate(username, today);
        }

        caseLabels.clear();
        caseMap.clear();

        while (cursor.moveToNext()) {
            int id = cursor.getInt(cursor.getColumnIndexOrThrow("case_id"));
            String desc = cursor.getString(cursor.getColumnIndexOrThrow("description"));
            String label = "Case ID " + id + ": " + desc;
            caseLabels.add(label);
            caseMap.put(label, id);
        }
        cursor.close();

        ArrayAdapter<String> adapter = new ArrayAdapter<>(this, android.R.layout.simple_list_item_1, caseLabels);
        caseListView.setAdapter(adapter);
    }
}
