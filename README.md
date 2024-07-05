# Calendar Event Management App

This is a calendar event management application featuring a dynamic and interactive UI. It uses Rive for animations and provides various functionalities for admins and users, including event management, user management, and notifications.

## Features

### Event Management

- **Dynamic Event Display**: The calendar dynamically updates to reflect the addition, deletion, or editing of events. For example, if there are 4 events on June 4, 4 dots will appear on that date.
- **Views**: 
  - **Monthly View**: View all events in a monthly calendar format.
  - **Weekly View**: View events for the week.
- **Event List**: A page where all events are displayed in a sorted list. Users can search for events using keywords.
- **Event Details**: Clicking on an event in the list shows its description. Clicking again hides the description.
- **Today's Events**: Displays today's events, indicating if an event has started or how much time is left until it starts, like a stopwatch.

### User Management

- **Admin Functions**: Admins can add, delete, and edit events. They can also add new users and admins.
- **Enable/Disable Users**: Admins can enable or disable users to control their login access.

### Notifications

- **Local Notifications**: Users receive a reminder notification 10 minutes before an event starts.
- **Push Notifications**: Sends notifications to all users when a new event is added by an admin.

### Authentication

- **Login/Logout**: Users can log in and out of their accounts. Disabled users will not be able to log in.

### Animations

- **Interactive Sidebar**: Uses Rive for an interactive and visually appealing sidebar.
- **Login Animations**: Engaging animations during the login process.

## Demo

Check out the working demo on YouTube: [Calendar Event Management App Demo](https://youtu.be/u_dMjbhMjoQ)

## Installation

1. **Clone the Repository**:
   ```sh
   git clone https://github.com/yourusername/your-repo-name.git
   cd your-repo-name
   ```

2. **Install Dependencies**:
   ```sh
   flutter pub get
   ```

3. **Configure Firebase**:
   - Follow the instructions to set up Firebase for your Flutter app.
   - Download the `google-services.json` file and place it in `android/app`.

4. **Run the App**:
   ```sh
   flutter run
   ```

## Building the Release APK

1. **Generate a Keystore**:
   ```sh
   keytool -genkey -v -keystore key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias myKeyAlias
   ```

2. **Configure the Keystore**:
   - Create a `key.properties` file in the `android` directory with the following content:
     ```properties
     storePassword=<your-store-password>
     keyPassword=<your-key-password>
     keyAlias=myKeyAlias
     storeFile=key.jks
     ```

3. **Build the APK**:
   ```sh
   flutter build apk --release
   ```

## Usage

1. **Admin Login**:
   - Admins can log in and access functionalities to manage events and users.

2. **User Login**:
   - Users can log in to view events, receive notifications, and more.

3. **Adding Events**:
   - Admins can add events through the event management interface. Events will be reflected dynamically on the calendar.

4. **Notifications**:
   - Users will receive local notifications 10 minutes before an event starts.
   - Admins can send push notifications to all users when a new event is added.

## Technologies Used

- **Flutter**: For building the cross-platform mobile application.
- **Firebase**: For authentication, Firestore database, and push notifications.
- **Rive**: For interactive animations.
- **Local Notifications**: For event reminders.

## Contributing

Feel free to open issues and submit pull requests. For major changes, please open an issue first to discuss what you would like to change.

## License

[MIT](https://choosealicense.com/licenses/mit/)

---

This README file provides an overview of the app's functionalities, setup instructions, and usage guidelines. Adjust the content as necessary to fit the specifics of your project.
