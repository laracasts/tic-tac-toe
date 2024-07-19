<template>
    <AuthenticatedLayout>
        {{ $page.props }}
    </AuthenticatedLayout>
</template>

<script setup>
import AuthenticatedLayout from "@/Layouts/AuthenticatedLayout.vue";
</script>
