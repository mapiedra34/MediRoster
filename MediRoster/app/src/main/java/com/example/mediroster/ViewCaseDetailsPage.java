package com.example.mediroster;

import android.content.Intent;
import android.database.Cursor;
import android.os.Bundle;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

import java.util.ArrayList;

public class ViewCaseDetailsPage extends AppCompatActivity {

    private TextView descText, shiftInfoText;
    private ListView nurseList;

    private UserDatabaseHelper dbHelper;
    private ArrayAdapter<String> nurseAdapter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_view_case_details);

        dbHelper = new UserDatabaseHelper(this);

        descText = findViewById(R.id.case_description);
        shiftInfoText = findViewById(R.id.shift_info);
        nurseList = findViewById(R.id.assigned_nurses_list);


        Intent intent = getIntent();
        int caseId = intent.getIntExtra("case_id", -1);

        if (caseId != -1) {
            loadCaseDetails(caseId);
        } else {
            descText.setText("No case selected.");
        }
    }

    private void loadCaseDetails(int caseId) {
        // Fetch case + shift info
        Cursor caseCursor = dbHelper.getCaseWithShift(caseId);
        if (caseCursor.moveToFirst()) {
            String desc = caseCursor.getString(caseCursor.getColumnIndexOrThrow("description"));
            String date = caseCursor.getString(caseCursor.getColumnIndexOrThrow("date"));
            String start = caseCursor.getString(caseCursor.getColumnIndexOrThrow("start_time"));
            String end = caseCursor.getString(caseCursor.getColumnIndexOrThrow("end_time"));

            descText.setText("Description: " + desc);
            shiftInfoText.setText("Shift: " + date + " | " + start + " - " + end);
        }
        caseCursor.close();

        // Fetch assigned nurses
        Cursor nurseCursor = dbHelper.getNursesAssignedToCase(caseId);
        ArrayList<String> nurses = new ArrayList<>();
        while (nurseCursor.moveToNext()) {
            nurses.add(nurseCursor.getString(0));
        }

        nurseCursor.close();

        nurseAdapter = new ArrayAdapter<>(this, android.R.layout.simple_list_item_1, nurses);
        nurseList.setAdapter(nurseAdapter);
    }
}
