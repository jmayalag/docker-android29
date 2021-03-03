FROM openjdk:8-jdk


ENV ANDROID_SDK_ROOT /opt/android-sdk-linux
# Preserved for backwards compatibility
ENV ANDROID_HOME /opt/android-sdk-linux

# Dependencies to execute Android builds
RUN apt-get update -qq
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y lib32stdc++6 lib32z1

# ------------------------------------------------------
# --- Download Android Command line Tools into $ANDROID_SDK_ROOT

RUN cd /opt \
    && wget -q https://dl.google.com/android/repository/commandlinetools-linux-6609375_latest.zip -O android-commandline-tools.zip \
    && mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools \
    && unzip -q android-commandline-tools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools \
    && rm android-commandline-tools.zip

ENV PATH ${PATH}:${ANDROID_SDK_ROOT}/platform-tools:${ANDROID_SDK_ROOT}/cmdline-tools/tools/bin

# ------------------------------------------------------
# --- Install Android SDKs and other build packages

# Other tools and resources of Android SDK
#  you should only install the packages you need!
# To get a full list of available options you can use:
#  sdkmanager --list

# Accept licenses before installing components, no need to echo y for each component
# License is valid for all the standard components in versions installed from this file
# Non-standard components: MIPS system images, preview versions, GDK (Google Glass) and Android Google TV require separate licenses, not accepted there
RUN yes | sdkmanager --licenses

RUN touch /root/.android/repositories.cfg

# Emulator and Platform tools
RUN yes | sdkmanager "platform-tools"

# SDKs
# Please keep these in descending order!
# The `yes` is for accepting all non-standard tool licenses.

RUN yes | sdkmanager --update --channel=3
# Please keep all sections in descending order!
RUN yes | sdkmanager \
    "platforms;android-29" \
    "build-tools;29.0.3" \
    "extras;android;m2repository" \
    "extras;google;m2repository" \
    "extras;google;google_play_services" \
    "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2" \
    "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.1" \
    "add-ons;addon-google_apis-google-23" \
    "add-ons;addon-google_apis-google-22" \
    "add-ons;addon-google_apis-google-21"

# Cleaning
RUN apt-get clean