# Retrospective: Why Building GNAV Was Hard

You asked for an honest answer regarding why I and other AIs struggled with what seems like a basic application. This document details the technical and systemic reasons for the friction encountered during development.

## 1. The "Basic App" Illusion
While the *user story* is simple ("I want to hike and see where I am"), the *technical implementation* chosen for GNAV is extremely complex.

A "Basic App" typically involves:
- REST API calls to a server.
- Displaying lists and forms.
- Simple local storage (SharedPrefs).

**GNAV is a System-Level Hybrid Application:**
- **Dual Runtime Environment:** We are essentially building **two concurrent applications**:
    1.  A **Java/Android Native** backend (Foreground Service, Location Manager, Room Database).
    2.  A **Dart/Flutter** frontend (UI, Drift Database, Map Rendering).
- **Inter-Process Communication (IPC):** These two apps must talk in real-time. Syncing state across this bridge (MethodChannels, EventChannels) introduces race conditions and serialization errors that "basic" apps never verify.
- **Shared Mutable State:** Both apps try to read/write the *same* SQLite database file on the filesystem simultaneously. This is a notorious source of corruption, locking issues, and version mismatches (as seen with the Version 3 vs Version 9 crash).

## 2. The AI Context Limitation
AI models work like a developer looking through a keyhole.
- **Limited Scope:** When I fix `AssetConfigLoader.java`, I often lose visibility of `MountainEntity.java`. I fix the method call in one file but assume the other file is already updated. If a tool call failed silently or was reverted 10 turns ago, I don't "know" that until the compiler screams.
- **Whac-a-Mole Debugging:** Because I cannot run the compiler myself in real-time (I rely on your feedback), I make a fix, break a dependency I can't see, and then have to fix that dependency, which might break the original file. This feedback loop is slow and frustrating for you.

## 3. The "Brain Transplant" Complexity
We switched architectures mid-flight.
- **Initial State:** Logic was in Dart (`TrackLoaderService`, `Geolocator`). It was buggy but "simple."
- **Migration:** We moved the brain (Math, Location, DB) to Java.
- **The Friction:** Porting logic isn't just translation. It's reimplementation.
    - Dart's `drift` library and Android's `Room` library handle schemas differently.
    - Dart's `File` paths and Android's `Context.getDatabasePath()` resolve differently.
    - Aligning these invisible contracts (e.g., "Where does Room actually store the file?") took multiple iterations because the documentation assumes you are using *only* Room or *only* Drift, not both on the same file.

## 4. Specific Failures in This Session
- **The Database Path:** I assumed standard behavior (`/databases/`), but Flutter/Drift uses `app_flutter/`. It took trial and error to align them because I couldn't "see" the filesystem structure directly.
- **The Constructor Mismatch:** I edited `MountainEntity` to add fields, but the edit might have been partial or failed. When I later wrote code to *use* those fields in `AssetConfigLoader`, the compiler flagged the inconsistency. To me, I had "fixed" it, but the reality on disk was different.

## Summary
The struggle wasn't because the features are complex, but because the **architecture required absolute synchronization between two completely different languages and ecosystems** (Java & Dart). AI struggles to maintain that perfect synchronization across dozens of files without a live compiler to check consistency instantly.

Moving forward, the architecture is now "correct" (Native Backend, Flutter Frontend), but getting here required wading through the messy reality of hybrid development.
