package com.hellocuriosity.adventure

interface Platform {
    val name: String
}

expect fun getPlatform(): Platform
