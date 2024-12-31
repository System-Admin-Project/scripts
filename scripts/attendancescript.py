import csv
import random
import os
from datetime import datetime, timedelta

# Function to read student names and matricules from students.txt
def read_students(file_path):
    students = []  # List to store student names
    matricules = []  # List to store matricules
    
    try:
        with open(file_path, mode='r') as file:
            reader = csv.reader(file)
            next(reader)  # Skip header
            for row in reader:
                if len(row) >= 2:  # Ensure we have at least Name and Matricule
                    students.append(row[0].strip())  # Student Name
                    matricules.append(row[1].strip())  # Matricule
    except Exception as e:
        print(f"Error reading students file: {e}")
    
    return students, matricules

# List of courses
courses = ["CEF401", "CEF473", "CEF405", "CEF415", "CEF451", "CEF427", "CEF431"]

# Days of the week
weekdays = ["Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

# Define time slots for lectures (7 AM to 5 PM, 2-hour duration)
def generate_random_time():
    start_time = datetime.strptime("07:00", "%H:%M")
    end_time = datetime.strptime("17:00", "%H:%M") - timedelta(hours=2)  # Last possible start time
    random_time = start_time + timedelta(minutes=random.randint(0, (end_time - start_time).seconds // 60))
    return random_time.strftime("%H:%M")

# Assign random days and times to each course
course_schedule = {}
for course in courses:
    days = random.sample(weekdays, 3)  # Randomly select three days per week
    time_slots = [generate_random_time() for _ in days]  # Generate random times for each day
    course_schedule[course] = list(zip(days, time_slots))

# Main function to generate attendance data
def main():
    # Path to the students.txt file
    students_file = "./Account-Management/Group_and_Txt_scriptandfile/students_users.txt"  # Update this path as needed
    
    # Read students and matricules from the file
    students, matricules = read_students(students_file)
    if not students or not matricules:
        print("No students or matricules found. Exiting...")
        return

    # Prompt for the base folder path
    base_folder = "../data/FET/Level400/SoftwareEng/Attendance/2025-2026/Semester-2"

    # Loop through courses and generate data for the semester
    for course_name, schedule in course_schedule.items():
        course_folder = os.path.join(base_folder, course_name)
        os.makedirs(course_folder, exist_ok=True)

        for week in range(1, 15):  # 14 weeks in a semester
            for day, lecture_time in schedule:  # Multiple lectures per week
                # Calculate the lecture date
                today = datetime.today()
                start_of_week = today - timedelta(days=today.weekday()) + timedelta(days=1)  # Start from Tuesday
                lecture_date = (start_of_week + timedelta(days=weekdays.index(day) + (week - 1) * 7)).strftime("%Y-%m-%d")

                # Define the output file path
                output_file = os.path.join(course_folder, f"{course_name}_attendance_{lecture_date}.csv")

                try:
                    # Create the CSV file and add header
                    with open(output_file, mode='w', newline='') as file:
                        writer = csv.writer(file)
                        writer.writerow(["Student Name", "Matricule", "Attendance", "Lecture Time"])

                        # Generate random attendance for each student
                        for student, matricule in zip(students, matricules):
                            attendance = "present" if random.choice([True, False]) else "absent"
                            writer.writerow([student, matricule, attendance, lecture_time])

                    print(f"Attendance data saved to {output_file}")

                except Exception as e:
                    print(f"An error occurred: {e}")

if __name__ == "__main__":
    main()
