import csv
import random
import os
from datetime import datetime, timedelta

# Predefined list of students and their matricules
students = [
   "John Doe" "Jane Smith" "Alice Johnson" "Bob Brown" "Charlie Davis"
    "Emily Clark" "Michael Miller" "Sarah Wilson" "James Taylor" "Laura Martin"
    "David Anderson" "Sophia Moore" "Daniel Harris" "Olivia Thompson" "Matthew White"
    "Isabella Lewis" "Andrew Walker" "Emma Hall" "Joseph King" "Mia Scott"
    "Christopher Green" "Amelia Adams" "Joshua Nelson" "Elizabeth Baker" "Ryan Carter"
    "Grace Mitchell" "Lucas Perez" "Chloe Roberts" "Ethan Turner" "Abigail Phillips"
]

# Generate matricules in the format FE22Axxx
matricules = [f"FE22A{str(i).zfill(3)}" for i in range(1, 31)]

#Change the students and matricules to come from the list Jamison generated

# List of courses
courses = ["CEF401", "CEF473", "CEF405", "CEF415", "CEF451","CEF427","CEF431"]

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
    days = random.sample(weekdays, 2)  # Randomly select two days per week
    time = generate_random_time()
    course_schedule[course] = [(day, time) for day in days]

# Main function to generate attendance data
def main():
    # Prompt for the base folder path
    base_folder = "../data/FET/Level400/SoftwareEng/Attendance/2024-2025/Semester-2"

    # Loop through courses and generate data for 2 weeks
    for course_name, schedule in course_schedule.items():
        course_folder = os.path.join(base_folder, course_name)
        os.makedirs(course_folder, exist_ok=True)

        for week in range(1, 4):  # Two weeks
            for day, lecture_time in schedule:  # Consistent days and times for the course
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