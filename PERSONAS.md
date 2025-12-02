# Persona-Based Testing Guide

This application supports multiple user roles (Personas) to simulate different workflows. Use the **Quick Login** buttons on the Login Screen to test each role.

## 1. Admin / Manager
*   **Role**: Full Access
*   **Capabilities**:
    *   View Dashboard (Revenue, Occupancy, Incidents).
    *   Manage Staff (Add, Edit, Delete).
    *   Manage Inventory (Stock, Alerts).
    *   Create Checklists for Housekeeping.
    *   View Attendance & Incidents.

## 2. Front Desk
*   **Role**: Guest Management
*   **Capabilities**:
    *   View Dashboard.
    *   Manage Rooms (Placeholder).
    *   Report Incidents.
    *   View Attendance.

## 3. Housekeeping Staff
*   **Role**: Task Execution
*   **Capabilities**:
    *   **My Tasks**: View assigned checklists and mark items as done.
    *   **Inventory**: View stock levels (read-only).
    *   Report Incidents (e.g., "Leaking Tap").
    *   Punch In/Out.

## 4. Waiter
*   **Role**: F&B Order Taking
*   **Capabilities**:
    *   **Order Taking**: Digital menu, Add to Cart, Send to Kitchen.
    *   Punch In/Out.

## 5. Chef (Kitchen)
*   **Role**: Order Preparation
*   **Capabilities**:
    *   **KDS (Kitchen Display System)**: View incoming orders, mark as Cooking/Ready.
    *   View Inventory.
    *   Punch In/Out.

## How to Test
1.  Launch the app.
2.  On the Login Screen, scroll down to "Quick Login (Dev)".
3.  Click a persona button (e.g., "Waiter").
4.  Observe the **Sidebar/Bottom Bar** changes to reflect the role's permissions.
