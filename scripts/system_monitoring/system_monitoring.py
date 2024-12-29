import os
import shutil
import zipfile
from datetime import datetime

# Define the folder containing the CSV files and the archive folder
csv_folder = "/root/scripts/data/FET/Level400/SoftwareEng/Attendance/2024-2025"  # Update this with your folder path
archive_folder = "/root/scripts/scripts/data-archives"         # Destination for archived files
threshold_mb = 50                         # Set your space threshold in MB

# Ensure the archive folder exists
os.makedirs(archive_folder, exist_ok=True)

def calculate_directory_size(directory):
    """Calculate the total size of all files in a directory, including subfolders."""
    total_size = 0
    for root, dirs, files in os.walk(directory):
        for file in files:
            file_path = os.path.join(root, file)
            total_size += os.path.getsize(file_path)
    return total_size

def archive_files(base_dir, archive_dir):
    """Archive files if the size exceeds the threshold."""
    archive_name = os.path.join(
        archive_dir, f"archive_{datetime.now().strftime('%Y%m%d_%H%M%S')}.zip"
    )
    with zipfile.ZipFile(archive_name, 'w') as zipf:
        for root, dirs, files in os.walk(base_dir):
            for file in files:
                file_path = os.path.join(root, file)
                arcname = os.path.relpath(file_path, base_dir)  # Preserve folder structure
                zipf.write(file_path, arcname)
    print(f"Files archived to: {archive_name}")
    return archive_name

def main():
    # Step 1: Calculate the size of the base directory
    total_size = calculate_directory_size(csv_folder)
    print(f"Total size of CSV files: {total_size / (1024 * 1024):.2f} MB")

    # Step 2: If size exceeds threshold, archive and delete files
    if total_size > threshold_mb * 1024 * 1024:
        print(f"Size exceeds threshold of {threshold_mb} MB. Archiving...")
        archive_name = archive_files(csv_folder, archive_folder)

        # Optional: Delete files after archiving
        for root, dirs, files in os.walk(csv_folder):
            for file in files:
                os.remove(os.path.join(root, file))
        print("Files archived and original files deleted.")
    else:
        print("Size is within the threshold. No action needed.")

if __name__ == "__main__":
    main()
